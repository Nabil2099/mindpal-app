from __future__ import annotations

import asyncio
import unittest

from fastapi import FastAPI
from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from app.api import chat as chat_api
from app.api import conversations as conversations_api
from app.database.base import Base
from app.models.conversation import Conversation
from app.models.user import User
from app.models.user_chat_memory import UserChatMemory


class _FakeMemoryService:
    async def summarize_and_store_conversation(
        self,
        db: AsyncSession,
        *,
        user_id: int,
        conversation_id: int,
        refresh_existing: bool = False,
    ):
        db.add(
            UserChatMemory(
                user_id=user_id,
                chat_id=conversation_id,
                summary="The user has been stressed lately and wants steadier routines around sleep and work.",
            )
        )
        await db.flush()


class ConversationCloseApiTests(unittest.TestCase):
    def setUp(self) -> None:
        self.engine = create_async_engine("sqlite+aiosqlite:///:memory:", echo=False)
        asyncio.run(self._create_schema())
        self.session_factory = sessionmaker(self.engine, class_=AsyncSession, expire_on_commit=False)

        self._old_memory_service = conversations_api.memory_service
        conversations_api.memory_service = _FakeMemoryService()

        self.app = FastAPI()

        async def _fake_db():
            async with self.session_factory() as session:
                yield session

        self.app.dependency_overrides[conversations_api.get_db_session] = _fake_db
        self.app.dependency_overrides[chat_api.get_db_session] = _fake_db
        self.app.include_router(conversations_api.router)
        self.app.include_router(chat_api.router)
        self.client = TestClient(self.app)

        asyncio.run(self._seed_data())

    def tearDown(self) -> None:
        conversations_api.memory_service = self._old_memory_service
        asyncio.run(self.engine.dispose())

    async def _create_schema(self) -> None:
        async with self.engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)

    async def _seed_data(self) -> None:
        async with self.session_factory() as session:
            session.add(User(id=1))
            session.add(Conversation(id=4, user_id=1, title="Open reflection"))
            await session.commit()

    async def _fetch_state(self) -> tuple[Conversation, list[UserChatMemory]]:
        async with self.session_factory() as session:
            conversation = (await session.execute(select(Conversation).where(Conversation.id == 4))).scalar_one()
            memories = (await session.execute(select(UserChatMemory).where(UserChatMemory.chat_id == 4))).scalars().all()
            return conversation, memories

    def test_close_endpoint_marks_conversation_closed_and_blocks_chat(self) -> None:
        response = self.client.post("/conversations/4/close", params={"user_id": 1})
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.json()["is_closed"])
        self.assertIsNotNone(response.json()["closed_at"])

        conversation, memories = asyncio.run(self._fetch_state())
        self.assertTrue(conversation.is_closed)
        self.assertEqual(len(memories), 1)

        chat_response = self.client.post(
            "/chat",
            json={"user_id": 1, "conversation_id": 4, "message": "Can I keep talking here?"},
        )
        self.assertEqual(chat_response.status_code, 409)
        self.assertEqual(chat_response.json()["detail"], "Conversation is closed")

    def test_reopen_endpoint_reopens_closed_conversation(self) -> None:
        close_response = self.client.post("/conversations/4/close", params={"user_id": 1})
        self.assertEqual(close_response.status_code, 200)
        self.assertTrue(close_response.json()["is_closed"])

        reopen_response = self.client.post("/conversations/4/reopen", params={"user_id": 1})
        self.assertEqual(reopen_response.status_code, 200)
        self.assertFalse(reopen_response.json()["is_closed"])
        self.assertIsNone(reopen_response.json()["closed_at"])

        conversation, _ = asyncio.run(self._fetch_state())
        self.assertFalse(conversation.is_closed)
        self.assertIsNone(conversation.closed_at)

    def test_close_endpoint_is_idempotent(self) -> None:
        first = self.client.post("/conversations/4/close", params={"user_id": 1})
        self.assertEqual(first.status_code, 200)
        second = self.client.post("/conversations/4/close", params={"user_id": 1})
        self.assertEqual(second.status_code, 200)

        _, memories = asyncio.run(self._fetch_state())
        self.assertEqual(len(memories), 1)


if __name__ == "__main__":
    unittest.main()
