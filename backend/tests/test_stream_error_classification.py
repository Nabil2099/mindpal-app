from __future__ import annotations

import asyncio
import unittest

import httpx

from app.rag.pipeline import RAGPipeline


class StreamErrorClassificationTests(unittest.TestCase):
    def test_cancelled_error_is_classified(self):
        message, code, retryable = RAGPipeline._classify_stream_error(asyncio.CancelledError())

        self.assertEqual(code, "stream_cancelled")
        self.assertTrue(retryable)
        self.assertIn("cancelled", message.lower())

    def test_timeout_error_is_classified(self):
        message, code, retryable = RAGPipeline._classify_stream_error(httpx.ReadTimeout("timed out"))

        self.assertEqual(code, "stream_timeout")
        self.assertTrue(retryable)
        self.assertIn("partial response was saved", message.lower())

    def test_transport_error_is_classified(self):
        message, code, retryable = RAGPipeline._classify_stream_error(httpx.ReadError("connection dropped"))

        self.assertEqual(code, "stream_transport_error")
        self.assertTrue(retryable)
        self.assertIn("connection", message.lower())

    def test_unknown_error_falls_back_to_generic(self):
        message, code, retryable = RAGPipeline._classify_stream_error(RuntimeError("boom"))

        self.assertEqual(code, "stream_error")
        self.assertTrue(retryable)
        self.assertEqual(message, "The response connection was interrupted. Partial response was saved.")


if __name__ == "__main__":
    unittest.main()

