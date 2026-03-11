# MindPal Backend

Backend for a personalized mental health RAG chatbot built with FastAPI, SQLite, Chroma, NetworkX, and Groq.

## Features

- FastAPI async API endpoints
- SQLite structured storage via SQLAlchemy ORM
- Chroma vector retrieval for RAG
- NetworkX graph relationships for behavior insights
- LLM-based emotion and habit detection via Groq
- Temporal analytics for hour/day trends
- User-scoped overview metrics, daily emotion/habit trends, and habit-emotion associations
- Closeable conversations with short long-term memory summaries

## Project Structure

```text
backend/
  app/
    main.py
    config.py
    database/
    models/
    schemas/
    services/
    rag/
    analytics/
    api/
  requirements.txt
```

## Setup

1. Create and activate a Python 3.11+ virtual environment.
2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Copy env file and set `GROQ_API_KEY`:

```bash
cp .env.example .env
```

4. Run API:

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Endpoints

- `POST /chat`
- `GET /conversations`
- `POST /conversations`
- `DELETE /conversations/{id}`
- `POST /conversations/{id}/close`
- `GET /insights/emotions`
- `GET /insights/habits`
- `GET /insights/time`
- `GET /insights/summary`
- `GET /insights/overview`
- `GET /insights/trends/emotions`
- `GET /insights/trends/habits`
- `GET /insights/associations/habit-emotion`

## Insights Notes

- All insights endpoints are user-scoped and require `user_id` query parameter.
- `/insights/emotions`, `/insights/habits`, `/insights/time`, and `/insights/summary` are preserved for backward compatibility.
- Habit-emotion links are association/co-occurrence signals from reflections and should not be interpreted as causation.

## Notes

- Knowledge base documents are seeded on startup into Chroma.
- Graph state is persisted to `mindpal_graph.json`.
- This iteration is single-tenant MVP scope (no auth).
- Closing a conversation stores one short summary in `user_chat_memory`; MindPal injects the latest 10 summaries into future prompts.
- Existing SQLite databases will pick up the new `conversations.is_closed` and `conversations.closed_at` columns at startup.
- Historical closed conversations can be backfilled with `"d:/mindpal v5/.venv/Scripts/python.exe" scripts/backfill_chat_memories.py` from the `backend/` directory.
