from __future__ import annotations

from sqlalchemy import inspect, text
from sqlalchemy.engine import Connection
from sqlalchemy.ext.asyncio import AsyncConnection


async def ensure_schema_updates(conn: AsyncConnection) -> None:
    """Apply additive schema updates for existing SQLite databases."""
    await conn.run_sync(_ensure_schema_updates)


def _ensure_schema_updates(sync_conn: Connection) -> None:
    inspector = inspect(sync_conn)
    tables = set(inspector.get_table_names())

    if "conversations" not in tables:
        return

    columns = {column["name"] for column in inspector.get_columns("conversations")}

    if "is_closed" not in columns:
        sync_conn.execute(text("ALTER TABLE conversations ADD COLUMN is_closed BOOLEAN NOT NULL DEFAULT 0"))

    if "closed_at" not in columns:
        sync_conn.execute(text("ALTER TABLE conversations ADD COLUMN closed_at DATETIME"))
