import { useEffect, useMemo, useState } from 'react'
import { useAppState } from '../state/useAppState'
import type { DailyEmotionTrend } from '../types/api'

interface InsightsDashboardProps {
  onOpenNavigation?: () => void
}

const emotionWeights: Record<string, number> = {
  joy: 1,
  excitement: 0.8,
  gratitude: 0.9,
  calm: 0.45,
  neutral: 0,
  anxiety: -0.65,
  fear: -0.75,
  frustration: -0.55,
  sadness: -0.9,
  anger: -0.8,
}

function normalizeEmotionLabel(label: string): string {
  return label.trim().toLowerCase()
}

function toMoodLevel(score: number): 'Balanced' | 'Uplifted' | 'Tender' | 'Heavy' {
  if (score >= 0.38) {
    return 'Uplifted'
  }
  if (score >= 0.08) {
    return 'Balanced'
  }
  if (score >= -0.24) {
    return 'Tender'
  }
  return 'Heavy'
}

function prettify(value: string): string {
  return value
    .replaceAll('_', ' ')
    .split(' ')
    .filter(Boolean)
    .map((word) => `${word[0]?.toUpperCase() ?? ''}${word.slice(1)}`)
    .join(' ')
}

function weekdayLabel(date: string): string {
  const parsed = new Date(date)
  if (Number.isNaN(parsed.getTime())) {
    return date.slice(0, 3).toUpperCase()
  }
  return parsed.toLocaleDateString(undefined, { weekday: 'short' }).toUpperCase()
}

function formatFullDate(date: string): string {
  const parsed = new Date(date)
  if (Number.isNaN(parsed.getTime())) return date
  return parsed.toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric' })
}

export default function InsightsDashboard({ onOpenNavigation }: InsightsDashboardProps) {
  const { insights, fetchInsights, isLoadingInsights, conversations, messagesByConversation } = useAppState()

  const moodSummary = useMemo(() => {
    if (!insights.emotions.length) {
      return { mood: 'Balanced' as const, entryCount: 0 }
    }

    const totals = insights.emotions.reduce(
      (acc, item) => {
        const normalized = normalizeEmotionLabel(item.label)
        const weight = emotionWeights[normalized] ?? 0
        acc.weighted += weight * item.count
        acc.entries += item.count
        return acc
      },
      { weighted: 0, entries: 0 },
    )

    const score = totals.entries ? totals.weighted / totals.entries : 0
    return { mood: toMoodLevel(score), entryCount: totals.entries }
  }, [insights.emotions])

  const streak = useMemo(() => {
    const allTimestamps = Object.values(messagesByConversation)
      .flat()
      .map((message) => message.timestamp)

    const seedTimestamps = allTimestamps.length ? allTimestamps : conversations.map((conversation) => conversation.created_at)

    if (!seedTimestamps.length) {
      return 0
    }

    const uniqueDays = Array.from(
      new Set(
        seedTimestamps.map((stamp) => {
          const date = new Date(stamp)
          return new Date(date.getFullYear(), date.getMonth(), date.getDate()).getTime()
        }),
      ),
    ).sort((a, b) => b - a)

    let current = 1
    for (let index = 1; index < uniqueDays.length; index += 1) {
      const previousDay = uniqueDays[index - 1]
      const nextDay = uniqueDays[index]
      const diff = Math.round((previousDay - nextDay) / (1000 * 60 * 60 * 24))
      if (diff === 1) {
        current += 1
        continue
      }
      break
    }

    return current
  }, [conversations, messagesByConversation])

  const timelineData = useMemo(() => {
    const recent = insights.emotionTrends.slice(-7)
    const enriched = recent.map((day) => {
      const total = day.total || day.emotions.reduce((sum, item) => sum + item.count, 0)
      const weighted = day.emotions.reduce((sum, item) => {
        const w = emotionWeights[normalizeEmotionLabel(item.label)] ?? 0
        return sum + w * item.count
      }, 0)
      const score = total > 0 ? weighted / total : 0
      return {
        day: weekdayLabel(day.date),
        total,
        source: day,
        moodLabel: toMoodLevel(score),
      }
    })
    const maxTotal = Math.max(...enriched.map((item) => item.total), 1)
    return enriched.map((item) => ({
      ...item,
      height: Math.max(34, Math.round((item.total / maxTotal) * 100)),
    }))
  }, [insights.emotionTrends])

  const [hoveredDayIndex, setHoveredDayIndex] = useState<number | null>(null)
  const [selectedDay, setSelectedDay] = useState<DailyEmotionTrend | null>(null)

  const selectedDayDetails = useMemo(() => {
    if (!selectedDay) return null
    const total = selectedDay.total || selectedDay.emotions.reduce((s, e) => s + e.count, 0)
    const weighted = selectedDay.emotions.reduce((s, e) => {
      const w = emotionWeights[normalizeEmotionLabel(e.label)] ?? 0
      return s + w * e.count
    }, 0)
    const score = total > 0 ? weighted / total : 0
    return {
      total,
      moodLabel: toMoodLevel(score),
      topEmotions: selectedDay.emotions.slice(0, 5),
      formattedDate: formatFullDate(selectedDay.date),
    }
  }, [selectedDay])

  const emotionFrequencyData = useMemo(() => {
    const top = insights.emotions.slice(0, 4).map((item) => ({
      label: prettify(item.label),
      count: item.count,
    }))
    const maxCount = Math.max(...top.map((item) => item.count), 1)

    return top.map((item) => ({
      ...item,
      height: Math.max(34, Math.round((item.count / maxCount) * 100)),
    }))
  }, [insights.emotions])

  const habitPairs = useMemo(
    () => {
      const total = insights.overview?.total_messages ?? 1
      return insights.habits.slice(0, 2).map((row) => ({
        habit: prettify(row.habit),
        count: row.count,
        percentage: Math.round((row.count / total) * 100),
      }))
    },
    [insights.habits, insights.overview],
  )

  const associationData = useMemo(
    () =>
      insights.habitEmotionLinks.slice(0, 6).map((row) => ({
        habit: prettify(row.habit),
        emotion: prettify(row.emotion),
        link_strength_pct: Math.round(row.link_strength * 100),
      })),
    [insights.habitEmotionLinks],
  )

  useEffect(() => {
    if (!selectedDay) return
    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') setSelectedDay(null)
    }
    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [selectedDay])

  useEffect(() => {
    void fetchInsights()
  }, [fetchInsights])

  return (
    <section className="h-full overflow-y-auto px-4 py-5 sm:px-6 sm:py-6 lg:px-8">
      <div className="mx-auto flex w-full max-w-6xl flex-col gap-6">
        <header className="flex items-start justify-between gap-4">
          <div>
          {onOpenNavigation ? (
            <button
              type="button"
              onClick={onOpenNavigation}
              className="subtle-icon-button mb-3"
              aria-label="Open sidebar"
            >
              <svg viewBox="0 0 24 24" className="h-4 w-4" fill="none" stroke="currentColor" strokeWidth="1.9" aria-hidden="true">
                <path d="M4 7h16" strokeLinecap="round" />
                <path d="M4 12h16" strokeLinecap="round" />
                <path d="M4 17h16" strokeLinecap="round" />
              </svg>
            </button>
          ) : null}
            <h1 className="font-heading text-3xl text-ink-900 sm:text-4xl">Emotional Patterns</h1>
            <p className="mt-1 text-sm text-ink-700">A curated view of your internal landscape.</p>
          </div>

          <div className="hidden items-center gap-2 rounded-full border border-clay-200/80 bg-white/90 p-1 sm:flex">
            <button type="button" className="rounded-full bg-clay-200 px-3 py-1 text-xs font-semibold text-ink-900">
              7 Days
            </button>
            <button type="button" className="rounded-full px-3 py-1 text-xs font-semibold text-ink-700/80">
              30 Days
            </button>
          </div>
        </header>

        {isLoadingInsights ? <p className="text-sm text-ink-700/75">Loading insights...</p> : null}

        <div className="grid gap-5 lg:grid-cols-[minmax(0,1.7fr)_290px]">
          <div className="space-y-5">
            <article className="rounded-[1.7rem] border border-clay-200/80 bg-white/95 p-5 shadow-soft sm:p-6">
              <div className="flex items-center justify-between">
                <h2 className="text-2xl font-semibold text-ink-900">Mood Timeline</h2>
                <p className="rounded-full bg-clay-100 px-3 py-1 text-xs font-semibold text-ink-700">Last 7 days</p>
              </div>

              {timelineData.length ? (
                <div className="mt-5 grid grid-cols-7 items-end gap-2 sm:gap-3">
                  {timelineData.map((item, index) => (
                    <div key={`${item.day}-${index}`} className="relative flex flex-col items-center gap-2">
                      {hoveredDayIndex === index && (
                        <div className="pointer-events-none absolute bottom-full left-1/2 z-20 mb-2 w-max max-w-[136px] -translate-x-1/2 rounded-[1rem] border border-clay-200/80 bg-white/97 p-2.5 text-center shadow-soft">
                          <p className="text-[10px] font-semibold uppercase tracking-[0.1em] text-clay-300">{item.moodLabel}</p>
                          <p className="mt-0.5 text-xs font-semibold text-ink-900">
                            {item.source.emotions[0] ? prettify(item.source.emotions[0].label) : '\u2014'}
                          </p>
                          <p className="mt-0.5 text-[10px] text-ink-700/70">
                            {item.total} {item.total === 1 ? 'entry' : 'entries'}
                          </p>
                        </div>
                      )}
                      <button
                        type="button"
                        aria-label={`View mood details for ${item.day}`}
                        className="flex h-40 w-full cursor-pointer items-end justify-center rounded-[1rem] bg-sand-50/95 p-1 transition-all hover:bg-sand-100/95 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-clay-300 sm:h-44"
                        onMouseEnter={() => setHoveredDayIndex(index)}
                        onMouseLeave={() => setHoveredDayIndex(null)}
                        onFocus={() => setHoveredDayIndex(index)}
                        onBlur={() => setHoveredDayIndex(null)}
                        onClick={() => setSelectedDay(item.source)}
                      >
                        <div
                          className={`w-full rounded-[0.9rem] transition-all ${
                            index === timelineData.length - 1 ? 'bg-clay-300/95' : 'bg-clay-100/95'
                          }`}
                          style={{ height: `${item.height}%` }}
                        />
                      </button>
                      <span className="text-[10px] font-semibold uppercase tracking-[0.12em] text-ink-700/70 sm:text-xs">
                        {item.day}
                      </span>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="mt-4 text-sm text-ink-700/70">No timeline data yet.</p>
              )}
            </article>

            <div className="grid gap-5 md:grid-cols-2">
              <article className="rounded-[1.5rem] border border-clay-200/70 bg-white/95 p-5 shadow-soft">
                <div className="flex items-center justify-between gap-3">
                  <h2 className="text-[1.35rem] font-semibold text-ink-900">Emotion Frequency</h2>
                  <span className="rounded-full bg-clay-100 px-3 py-1 text-[10px] font-semibold uppercase tracking-[0.14em] text-ink-700">
                    Top 4
                  </span>
                </div>
                {emotionFrequencyData.length ? (
                  <div className="mt-5 grid grid-cols-4 items-end gap-2 sm:gap-3">
                    {emotionFrequencyData.map((item, index) => (
                      <div key={item.label} className="flex flex-col items-center gap-2">
                        <span className="text-[10px] font-semibold uppercase tracking-[0.12em] text-ink-700/65 sm:text-xs">
                          {item.count}
                        </span>
                        <div className="flex h-36 w-full items-end justify-center rounded-[1rem] bg-sand-50/95 p-1 sm:h-40">
                          <div
                            className={`w-full rounded-[0.9rem] transition-all ${index === 0 ? 'bg-clay-300/95' : 'bg-clay-100/95'}`}
                            style={{ height: `${item.height}%` }}
                          />
                        </div>
                        <span className="text-center text-[10px] font-semibold uppercase leading-tight tracking-[0.08em] text-ink-700/70 sm:text-xs">
                          {item.label}
                        </span>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="mt-4 text-sm text-ink-700/70">No emotion insights yet.</p>
                )}
              </article>

              <article className="rounded-[1.5rem] border border-clay-200/70 bg-white/95 p-5 shadow-soft">
                <div className="flex items-center justify-between gap-3">
                  <h2 className="text-[1.35rem] font-semibold text-ink-900">Habit Frequency</h2>
                  <span className="text-[10px] font-bold uppercase tracking-[0.16em] text-clay-300">Most Frequent</span>
                </div>

                {habitPairs.length ? (
                  <div className="mt-4 space-y-3.5">
                    {habitPairs.map((pair) => (
                      <div key={pair.habit} className="rounded-soft border border-clay-100 bg-sand-50/70 p-3">
                        <p className="text-sm font-semibold text-ink-900">{pair.habit}</p>
                        <p className="mt-0.5 text-xs text-ink-700">{pair.percentage}% of messages</p>
                        <div className="mt-2 flex items-center gap-2">
                          <div className="h-2 w-full rounded-full bg-clay-100">
                            <div className="h-2 rounded-full bg-clay-300" style={{ width: `${Math.max(pair.percentage, 5)}%` }} />
                          </div>
                          <span className="text-xs font-semibold text-ink-700">{pair.percentage}%</span>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="mt-4 text-sm text-ink-700/70">No habit data yet.</p>
                )}
              </article>
            </div>
            <article className="rounded-[1.5rem] border border-clay-200/80 bg-white/95 p-5 shadow-soft">
              <div className="flex items-center justify-between gap-3">
                <h2 className="text-xl font-semibold text-ink-900">Detailed Patterns</h2>
                {insights.overview ? (
                  <p className="text-xs font-semibold uppercase tracking-[0.14em] text-ink-700/65">
                    {insights.overview.total_messages} Messages / {insights.overview.active_days} Active Days
                  </p>
                ) : null}
              </div>

              {associationData.length ? (
                <div className="mt-4 space-y-2.5">
                  {associationData.map((row) => (
                    <div key={`${row.habit}-${row.emotion}`} className="rounded-soft border border-clay-100 bg-sand-50/65 px-3.5 py-3">
                      <div className="flex items-center justify-between gap-2">
                        <p className="text-sm font-semibold text-ink-900">{row.habit}</p>
                        <span className="text-xs font-semibold text-ink-700">{row.link_strength_pct}%</span>
                      </div>
                      <p className="mt-0.5 text-xs text-ink-700">Linked with {row.emotion.toLowerCase()}</p>
                      <div className="mt-2 h-2 rounded-full bg-clay-100">
                        <div className="h-2 rounded-full bg-clay-300" style={{ width: `${Math.max(row.link_strength_pct, 4)}%` }} />
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="mt-4 text-sm text-ink-700/70">No association data yet.</p>
              )}
            </article>
          </div>

          <aside className="space-y-5">
            <section>
              <p className="text-[11px] font-semibold uppercase tracking-[0.2em] text-ink-700/65">Today's Mood Map</p>
              <article className="mt-3 rounded-[1.35rem] border border-clay-200/80 bg-clay-100/75 px-4 py-5">
                <p className="text-4xl font-semibold text-clay-400">{moodSummary.mood}</p>
                <p className="mt-1 text-xs text-ink-700/80">Based on {moodSummary.entryCount} insight entries today</p>
                {insights.overview?.dominant_emotion ? (
                  <p className="mt-4 text-xs uppercase tracking-[0.12em] text-ink-700/70">
                    Dominant emotion: {prettify(insights.overview.dominant_emotion)}
                  </p>
                ) : null}
              </article>
            </section>

            <article className="rounded-[1.2rem] bg-[#1f1813] px-4 py-5 text-center text-sand-50 shadow-soft">
              <p className="text-3xl leading-none">{streak}</p>
              <p className="mt-1 text-2xl font-semibold">Day Streak</p>
              <p className="mt-1 text-[11px] uppercase tracking-[0.13em] text-sand-100/70">You're doing great</p>
            </article>

            <article className="rounded-[1.2rem] border border-clay-200/75 bg-white/95 p-4 shadow-soft">
              <p className="text-xs font-semibold uppercase tracking-[0.16em] text-ink-700/65">Top Habits</p>
              {insights.habits.length ? (
                <div className="mt-3 space-y-2">
                  {insights.habits.slice(0, 3).map((habit) => (
                    <div key={habit.habit} className="flex items-center justify-between text-sm">
                      <span className="text-ink-800">{prettify(habit.habit)}</span>
                      <span className="font-semibold text-ink-800">{habit.count}</span>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="mt-2 text-sm text-ink-700/70">No habit highlights yet.</p>
              )}
            </article>
          </aside>
        </div>

        {!insights.overview && !insights.emotions.length && !insights.habitEmotionLinks.length ? (
          <p className="text-sm text-ink-700/70">No insights available yet. Continue reflecting to unlock your dashboard.</p>
        ) : null}

        {insights.overview ? (
          <article className="rounded-[1.2rem] border border-clay-200/70 bg-white/85 px-4 py-3 text-xs text-ink-700/85">
            Snapshot: {insights.overview.total_messages} total messages over {insights.overview.active_days} active days
            {insights.overview.dominant_habit ? `, led by ${prettify(insights.overview.dominant_habit).toLowerCase()}` : ''}.
          </article>
        ) : null}
      </div>

      {selectedDay && selectedDayDetails && (
        <div
          className="fixed inset-0 z-50 flex items-end justify-center sm:items-center"
          role="dialog"
          aria-modal="true"
          aria-label={`Mood details for ${selectedDayDetails.formattedDate}`}
        >
          <button
            type="button"
            className="absolute inset-0 bg-ink-900/25"
            aria-label="Close"
            onClick={() => setSelectedDay(null)}
          />
          <div className="relative z-10 mx-0 w-full max-w-sm rounded-t-[1.7rem] border border-clay-200/80 bg-white/98 p-6 shadow-soft sm:mx-4 sm:rounded-[1.7rem]">
            <div className="flex items-start justify-between gap-3">
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.14em] text-ink-700/60">
                  {selectedDayDetails.formattedDate}
                </p>
                <h3 className="mt-1 text-2xl font-semibold text-ink-900">{selectedDayDetails.moodLabel}</h3>
              </div>
              <button
                type="button"
                className="subtle-icon-button mt-0.5 shrink-0"
                aria-label="Close details"
                onClick={() => setSelectedDay(null)}
              >
                <svg viewBox="0 0 24 24" className="h-3.5 w-3.5" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden="true">
                  <path d="M18 6L6 18" strokeLinecap="round" />
                  <path d="M6 6l12 12" strokeLinecap="round" />
                </svg>
              </button>
            </div>
            <p className="mt-2 text-sm text-ink-700/70">
              {selectedDayDetails.total} emotion {selectedDayDetails.total === 1 ? 'entry' : 'entries'} recorded.
            </p>
            {selectedDayDetails.topEmotions.length ? (
              <div className="mt-4 space-y-2.5">
                {selectedDayDetails.topEmotions.map((e) => (
                  <div key={e.label} className="rounded-soft border border-clay-100 bg-sand-50/70 px-3.5 py-2.5">
                    <div className="flex items-center justify-between gap-2">
                      <p className="text-sm font-semibold text-ink-900">{prettify(e.label)}</p>
                      <span className="text-xs font-semibold text-ink-700">{e.count}</span>
                    </div>
                    <div className="mt-1.5 h-1.5 w-full rounded-full bg-clay-100">
                      <div
                        className="h-1.5 rounded-full bg-clay-300"
                        style={{
                          width: `${Math.max(Math.round((e.count / (selectedDayDetails.topEmotions[0]?.count ?? 1)) * 100), 5)}%`,
                        }}
                      />
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <p className="mt-4 text-sm text-ink-700/70">No emotion data for this day.</p>
            )}
          </div>
        </div>
      )}
    </section>
  )
}
