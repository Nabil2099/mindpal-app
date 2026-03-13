from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, JSON, String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base


class RecommendationInteraction(Base):
    __tablename__ = "recommendation_interactions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    batch_id: Mapped[int | None] = mapped_column(
        ForeignKey("recommendation_batches.id", ondelete="CASCADE"),
        nullable=True,
        index=True,
    )
    item_id: Mapped[int | None] = mapped_column(
        ForeignKey("recommendation_items.id", ondelete="CASCADE"),
        nullable=True,
        index=True,
    )
    event_type: Mapped[str] = mapped_column(String(64), nullable=False, index=True)
    event_payload_json: Mapped[dict] = mapped_column(JSON, default=dict, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False, index=True)

    user = relationship("User", back_populates="recommendation_interactions")
    batch = relationship("RecommendationBatch", back_populates="interactions")
    item = relationship("RecommendationItem", back_populates="interactions")