from __future__ import annotations

import unittest
from datetime import datetime
from types import MethodType, SimpleNamespace

from app.rag.pipeline import RAGPipeline


class _FakeLLMRecoverFromStreamFailure:
    async def stream_chat_tokens(self, _prompt: str, *, max_tokens: int | None = None):
        if False:
            yield ""
        raise RuntimeError("stream transport failed")

    async def generate_chat(self, _prompt: str, *, temperature: float | None = None, max_tokens: int | None = None) -> str:
        return "Recovered full response"


class StreamRecoveryTests(unittest.IsolatedAsyncioTestCase):
    async def test_stream_failure_without_tokens_recovers_via_generate_chat(self):
        pipeline = object.__new__(RAGPipeline)
        pipeline.llm = _FakeLLMRecoverFromStreamFailure()

        async def _prepare(self, *, db, conversation_id, user_id, user_text):
            return SimpleNamespace(
                conversation_id=conversation_id,
                user_id=user_id,
                user_message_id=101,
                response_max_tokens=64,
                final_prompt="prompt",
            )

        async def _finalize(self, *, db, context, assistant_text):
            return SimpleNamespace(id=202, timestamp=datetime(2026, 3, 11, 1, 0, 0), content=assistant_text)

        pipeline._prepare_generation_context = MethodType(_prepare, pipeline)
        pipeline._finalize_assistant_response = MethodType(_finalize, pipeline)

        events: list[dict] = []
        async for event in pipeline.run_stream(
            db=object(),
            conversation_id=9,
            user_id=1,
            user_text="hello",
        ):
            events.append(event)

        self.assertEqual(events[0]["type"], "message_start")
        self.assertEqual(events[-1]["type"], "message_end")
        self.assertEqual(events[-1]["response"], "Recovered full response")
        self.assertFalse(any(event.get("type") == "error" for event in events))


if __name__ == "__main__":
    unittest.main()

