from __future__ import annotations

import unittest

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from app.database.base import Base
from app.models.conversation import Conversation
from app.models.message import Message, MessageRole
from app.models.user import User
from app.rag.pipeline import RAGPipeline


class _FakeLLM:
    def __init__(self, response: str = "Finding Balance with Work Stress", should_fail: bool = False) -> None:
        self.response = response
        self.should_fail = should_fail
        self.calls = 0

    async def generate_chat(self, _prompt: str, *, temperature: float | None = None, max_tokens: int | None = None) -> str:
        self.calls += 1
        if self.should_fail:
            raise RuntimeError("LLM unavailable")
        return self.response


class ConversationTitleGenerationTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self) -> None:
        self.engine = create_async_engine("sqlite+aiosqlite:///:memory:", echo=False)
        async with self.engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)

        self.session_factory = sessionmaker(self.engine, class_=AsyncSession, expire_on_commit=False)

    async def asyncTearDown(self) -> None:
        await self.engine.dispose()

    async def _seed_conversation(self, title: str) -> tuple[AsyncSession, Conversation]:
        session = self.session_factory()
        user = User(id=1)
        session.add(user)
        conversation = Conversation(user_id=1, title=title)
        session.add(conversation)
        await session.flush()
        return session, conversation

    async def test_generates_title_after_first_full_exchange(self) -> None:
        session, conversation = await self._seed_conversation("New Reflection")

        session.add(Message(conversation_id=conversation.id, role=MessageRole.USER, content="I feel overwhelmed by work."))
        session.add(Message(conversation_id=conversation.id, role=MessageRole.ASSISTANT, content="Let's break your day into smaller tasks."))
        await session.flush()

        pipeline = object.__new__(RAGPipeline)
        pipeline.llm = _FakeLLM(response="Managing Work Stress with Small Steps")
        pipeline.placeholder_titles = {"New Reflection", "New Conversation"}
        pipeline.max_generated_title_words = 2

        await pipeline._maybe_generate_conversation_title(
            db=session,
            conversation_id=conversation.id,
            latest_user_text="I feel overwhelmed by work.",
            latest_assistant_text="Let's break your day into smaller tasks.",
        )
        await session.flush()

        updated = (await session.execute(select(Conversation).where(Conversation.id == conversation.id))).scalar_one()
        self.assertEqual(updated.title, "Managing Work")
        self.assertEqual(pipeline.llm.calls, 1)

        await session.close()

    async def test_does_not_regenerate_custom_title(self) -> None:
        session, conversation = await self._seed_conversation("Custom Journal Title")

        session.add(Message(conversation_id=conversation.id, role=MessageRole.USER, content="User note"))
        session.add(Message(conversation_id=conversation.id, role=MessageRole.ASSISTANT, content="Assistant note"))
        await session.flush()

        pipeline = object.__new__(RAGPipeline)
        pipeline.llm = _FakeLLM(response="Should Not Be Used")
        pipeline.placeholder_titles = {"New Reflection", "New Conversation"}
        pipeline.max_generated_title_words = 2

        await pipeline._maybe_generate_conversation_title(
            db=session,
            conversation_id=conversation.id,
            latest_user_text="User note",
            latest_assistant_text="Assistant note",
        )

        unchanged = (await session.execute(select(Conversation).where(Conversation.id == conversation.id))).scalar_one()
        self.assertEqual(unchanged.title, "Custom Journal Title")
        self.assertEqual(pipeline.llm.calls, 0)

        await session.close()

    async def test_does_not_regenerate_after_first_exchange(self) -> None:
        session, conversation = await self._seed_conversation("New Reflection")

        session.add(Message(conversation_id=conversation.id, role=MessageRole.USER, content="First user"))
        session.add(Message(conversation_id=conversation.id, role=MessageRole.ASSISTANT, content="First assistant"))
        session.add(Message(conversation_id=conversation.id, role=MessageRole.USER, content="Second user"))
        session.add(Message(conversation_id=conversation.id, role=MessageRole.ASSISTANT, content="Second assistant"))
        await session.flush()

        pipeline = object.__new__(RAGPipeline)
        pipeline.llm = _FakeLLM(response="Should Not Be Used")
        pipeline.placeholder_titles = {"New Reflection", "New Conversation"}
        pipeline.max_generated_title_words = 2

        await pipeline._maybe_generate_conversation_title(
            db=session,
            conversation_id=conversation.id,
            latest_user_text="Second user",
            latest_assistant_text="Second assistant",
        )

        unchanged = (await session.execute(select(Conversation).where(Conversation.id == conversation.id))).scalar_one()
        self.assertEqual(unchanged.title, "New Reflection")
        self.assertEqual(pipeline.llm.calls, 0)

        await session.close()

    async def test_generation_failure_keeps_placeholder(self) -> None:
        session, conversation = await self._seed_conversation("New Reflection")

        session.add(Message(conversation_id=conversation.id, role=MessageRole.USER, content="I had a rough morning."))
        session.add(Message(conversation_id=conversation.id, role=MessageRole.ASSISTANT, content="Thanks for sharing, let's reset your routine."))
        await session.flush()

        pipeline = object.__new__(RAGPipeline)
        pipeline.llm = _FakeLLM(should_fail=True)
        pipeline.placeholder_titles = {"New Reflection", "New Conversation"}
        pipeline.max_generated_title_words = 2

        await pipeline._maybe_generate_conversation_title(
            db=session,
            conversation_id=conversation.id,
            latest_user_text="I had a rough morning.",
            latest_assistant_text="Thanks for sharing, let's reset your routine.",
        )

        unchanged = (await session.execute(select(Conversation).where(Conversation.id == conversation.id))).scalar_one()
        self.assertEqual(unchanged.title, "New Reflection")
        self.assertEqual(pipeline.llm.calls, 1)

        await session.close()


if __name__ == "__main__":
    unittest.main()

