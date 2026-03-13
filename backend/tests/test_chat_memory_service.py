from __future__ import annotations

from datetime import datetime
import unittest

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from app.database.base import Base
from app.models.conversation import Conversation
from app.models.message import Message, MessageRole
from app.models.user import User
from app.models.user_chat_memory import UserChatMemory
from app.services.chat_memory_service import ChatMemoryService


class _FakeLLM:
    def __init__(self) -> None:
        self.calls = 0

    async def generate_chat(self, prompt: str, *, temperature: float | None = None, max_tokens: int | None = None) -> str:
        self.calls += 1
        return f"Summary {self.calls}: The user shared ongoing work stress, sleep disruption, and a goal to build steadier routines."


class ChatMemoryServiceTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self) -> None:
        self.engine = create_async_engine("sqlite+aiosqlite:///:memory:", echo=False)
        async with self.engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)

        self.session_factory = sessionmaker(self.engine, class_=AsyncSession, expire_on_commit=False)

    async def asyncTearDown(self) -> None:
        await self.engine.dispose()

    async def test_prunes_to_latest_ten_memories_per_user(self) -> None:
        session = self.session_factory()
        session.add(User(id=1))
        await session.flush()

        llm = _FakeLLM()
        service = ChatMemoryService(llm)

        for index in range(12):
            conversation = Conversation(user_id=1, title=f"Reflection {index}", is_closed=True)
            session.add(conversation)
            await session.flush()

            session.add(
                Message(
                    conversation_id=conversation.id,
                    role=MessageRole.USER,
                    content="I keep feeling stretched thin between work deadlines and poor sleep, and I want to rebuild a calmer routine.",
                )
            )
            session.add(
                Message(
                    conversation_id=conversation.id,
                    role=MessageRole.ASSISTANT,
                    content="Let's note the stress pattern and focus on a smaller evening reset habit you can repeat.",
                )
            )
            await session.flush()
            await service.summarize_and_store_conversation(session, user_id=1, conversation_id=conversation.id)

        await session.commit()

        rows = (
            await session.execute(select(UserChatMemory).where(UserChatMemory.user_id == 1).order_by(UserChatMemory.chat_id.asc()))
        ).scalars().all()

        self.assertEqual(len(rows), 10)
        self.assertEqual([row.chat_id for row in rows], list(range(3, 13)))
        self.assertEqual(llm.calls, 12)
        await session.close()

    async def test_backfill_is_idempotent_for_closed_conversations(self) -> None:
        session = self.session_factory()
        session.add(User(id=7))
        await session.flush()

        for index in range(2):
            conversation = Conversation(user_id=7, title=f"Closed {index}", is_closed=True)
            session.add(conversation)
            await session.flush()
            session.add(
                Message(
                    conversation_id=conversation.id,
                    role=MessageRole.USER,
                    content="I have been anxious about family plans and want to stay consistent with journaling this month.",
                )
            )
            session.add(
                Message(
                    conversation_id=conversation.id,
                    role=MessageRole.ASSISTANT,
                    content="It sounds like stability and follow-through matter to you right now, especially around family stress.",
                )
            )

        await session.flush()
        service = ChatMemoryService(_FakeLLM())

        first_created = await service.backfill_closed_conversations(session, user_id=7)
        second_created = await service.backfill_closed_conversations(session, user_id=7)
        await session.commit()

        total_rows = (await session.execute(select(UserChatMemory).where(UserChatMemory.user_id == 7))).scalars().all()
        self.assertEqual(first_created, 2)
        self.assertEqual(second_created, 0)
        self.assertEqual(len(total_rows), 2)
        await session.close()

    async def test_refresh_existing_memory_after_new_messages(self) -> None:
        session = self.session_factory()
        session.add(User(id=9))
        await session.flush()

        conversation = Conversation(user_id=9, title="Reopened", is_closed=True)
        session.add(conversation)
        await session.flush()

        session.add(
            Message(
                conversation_id=conversation.id,
                role=MessageRole.USER,
                content="Work has been overwhelming and I need a realistic evening routine.",
            )
        )
        session.add(
            Message(
                conversation_id=conversation.id,
                role=MessageRole.ASSISTANT,
                content="Let's pick one small evening step you can sustain.",
            )
        )
        await session.flush()

        llm = _FakeLLM()
        service = ChatMemoryService(llm)

        first_memory = await service.summarize_and_store_conversation(session, user_id=9, conversation_id=conversation.id)
        self.assertIsNotNone(first_memory)
        self.assertEqual(llm.calls, 1)

        # Force the existing memory timestamp old to simulate a prior close cycle.
        first_memory.created_at = datetime(2000, 1, 1)

        session.add(
            Message(
                conversation_id=conversation.id,
                role=MessageRole.USER,
                content="I also notice late scrolling makes sleep much worse.",
            )
        )
        await session.flush()

        refreshed_memory = await service.summarize_and_store_conversation(
            session,
            user_id=9,
            conversation_id=conversation.id,
            refresh_existing=True,
        )
        await session.commit()

        self.assertIsNotNone(refreshed_memory)
        self.assertEqual(refreshed_memory.id, first_memory.id)
        self.assertEqual(llm.calls, 2)


if __name__ == "__main__":
    unittest.main()
