from __future__ import annotations

import argparse
import asyncio

from app.database.session import SessionLocal
from app.services.chat_memory_service import ChatMemoryService


async def _run(user_id: int | None) -> None:
    service = ChatMemoryService()
    async with SessionLocal() as session:
        created = await service.backfill_closed_conversations(session, user_id=user_id)
        await session.commit()
    print(f"Created {created} chat memory summaries.")


def main() -> None:
    parser = argparse.ArgumentParser(description="Backfill chat memory summaries for closed MindPal conversations.")
    parser.add_argument("--user-id", type=int, default=None, help="Limit backfill to one user.")
    args = parser.parse_args()
    asyncio.run(_run(args.user_id))


if __name__ == "__main__":
    main()
