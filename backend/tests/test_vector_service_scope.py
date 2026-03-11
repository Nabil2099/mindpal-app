from __future__ import annotations

from datetime import datetime
import unittest

from app.services.vector_service import VectorService


class _FakeLLM:
    async def embed_texts(self, _texts: list[str]) -> list[list[float]]:
        return [[0.1, 0.2, 0.3]]


class _FakeCollection:
    def __init__(self) -> None:
        self.last_query_kwargs: dict | None = None
        self.last_upsert_kwargs: dict | None = None

    def query(self, **kwargs):
        self.last_query_kwargs = kwargs
        return {"documents": [["matched memory"]]}

    def upsert(self, **kwargs):
        self.last_upsert_kwargs = kwargs


class VectorServiceScopeTests(unittest.IsolatedAsyncioTestCase):
    async def asyncSetUp(self):
        self.service = object.__new__(VectorService)
        self.service.llm = _FakeLLM()
        self.service.messages_collection = _FakeCollection()

    async def test_search_similar_messages_scopes_by_user(self):
        docs = await self.service.search_similar_messages("sleep", 4, user_id=7)

        self.assertEqual(docs, ["matched memory"])
        assert self.service.messages_collection.last_query_kwargs is not None
        self.assertEqual(self.service.messages_collection.last_query_kwargs["where"], {"user_id": "7"})

    async def test_search_similar_messages_can_scope_to_conversation(self):
        docs = await self.service.search_similar_messages("sleep", 4, user_id=7, conversation_id=11)

        self.assertEqual(docs, ["matched memory"])
        assert self.service.messages_collection.last_query_kwargs is not None
        self.assertEqual(
            self.service.messages_collection.last_query_kwargs["where"],
            {
                "$and": [
                    {"user_id": "7"},
                    {"conversation_id": "11"},
                ]
            },
        )

    async def test_upsert_message_embedding_persists_user_metadata(self):
        now = datetime(2026, 3, 11, 10, 30, 0)

        await self.service.upsert_message_embedding(
            vector_id="msg-1",
            content="I felt better today",
            user_id=3,
            conversation_id=10,
            message_id=1,
            timestamp=now,
            emotions=[{"label": "relief"}],
            habits=[{"habit": "walking"}],
            role="user",
        )

        assert self.service.messages_collection.last_upsert_kwargs is not None
        metadata = self.service.messages_collection.last_upsert_kwargs["metadatas"][0]
        self.assertEqual(metadata["user_id"], "3")
        self.assertEqual(metadata["conversation_id"], "10")
        self.assertEqual(metadata["message_id"], "1")
        self.assertEqual(metadata["timestamp"], now.isoformat())


if __name__ == "__main__":
    unittest.main()

