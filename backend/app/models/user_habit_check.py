from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database.base import Base


class UserHabitCheck(Base):
    __tablename__ = "user_habit_checks"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    habit_id: Mapped[int] = mapped_column(ForeignKey("user_habits.id", ondelete="CASCADE"), nullable=False, index=True)
    check_date: Mapped[date] = mapped_column(Date, nullable=False, index=True)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=True, nullable=False)
    completed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, nullable=False, index=True)

    habit = relationship("UserHabit", back_populates="checks")