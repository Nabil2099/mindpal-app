export type AppTab = 'chat' | 'insights' | 'recommendations'

export type RecommendationCategory = 'balance' | 'calm' | 'energy' | 'focus' | 'reflection'
export type RecommendationKind = 'timed_action' | 'habit' | 'instant_action' | 'reflection'
export type RecommendationStatus = 'pending' | 'selected' | 'completed'

export interface Conversation {
  id: number
  user_id: number
  title: string
  created_at: string
  is_closed: boolean
  closed_at: string | null
}

export interface ConversationListResponse {
  conversations: Conversation[]
}

export interface CreateConversationRequest {
  user_id: number
  title?: string
}

export type MessageRole = 'user' | 'assistant'

export interface Message {
  id: number
  conversation_id: number
  role: MessageRole
  content: string
  timestamp: string
}

export interface ConversationMessagesResponse {
  messages: Message[]
}

export interface ChatRequest {
  user_id: number
  conversation_id: number
  message: string
}

export interface ChatResponse {
  conversation_id: number
  user_message_id: number
  assistant_message_id: number
  response: string
  timestamp: string
}

export interface EmotionInsight {
  label: string
  count: number
}

export interface HabitInsight {
  habit: string
  count: number
}

export interface TimePatternInsight {
  hour_of_day: number
  top_emotion: string
  message_count: number
}

export interface OverviewInsight {
  total_messages: number
  active_days: number
  dominant_emotion: string | null
  dominant_habit: string | null
}

export interface DailyEmotionPoint {
  label: string
  count: number
}

export interface DailyEmotionTrend {
  date: string
  total: number
  emotions: DailyEmotionPoint[]
}

export interface DailyHabitPoint {
  habit: string
  count: number
}

export interface DailyHabitTrend {
  date: string
  total: number
  habits: DailyHabitPoint[]
}

export interface HabitEmotionLinkInsight {
  habit: string
  emotion: string
  co_occurrence: number
  habit_total: number
  link_strength: number
}

export interface InsightsBundle {
  emotions: EmotionInsight[]
  habits: HabitInsight[]
  timePatterns: TimePatternInsight[]
  overview: OverviewInsight | null
  emotionTrends: DailyEmotionTrend[]
  habitTrends: DailyHabitTrend[]
  habitEmotionLinks: HabitEmotionLinkInsight[]
}

export interface RecommendationItem {
  id: number
  batch_id: number
  position: number
  category: string
  kind: RecommendationKind
  title: string
  rationale: string
  action_payload: Record<string, unknown>
  estimated_duration_minutes: number | null
  follow_up_text: string | null
  status: RecommendationStatus
  completed_at: string | null
  created_at: string
}

export interface RecommendationBatch {
  id: number
  user_id: number
  category: string
  batch_date: string
  is_active: boolean
  created_at: string
  items: RecommendationItem[]
}

export interface RecommendationHistoryResponse {
  batches: RecommendationBatch[]
}

export interface RecommendationGenerationRequest {
  user_id: number
  category: RecommendationCategory
}

export interface RecommendationInteractionRequest {
  user_id: number
  event_type: string
  payload?: Record<string, unknown>
}

export interface UserHabit {
  id: number
  user_id: number
  source_recommendation_item_id: number | null
  name: string
  category: string
  cue_text: string | null
  reason_text: string | null
  is_active: boolean
  created_at: string
  archived_at: string | null
}

export interface DailyHabitChecklistItem {
  habit: UserHabit
  is_completed: boolean
  completed_at: string | null
}

export interface DailyHabitChecklistResponse {
  date: string
  habits: DailyHabitChecklistItem[]
}

export interface HabitCheckRequest {
  user_id: number
  date?: string
  completed: boolean
}
