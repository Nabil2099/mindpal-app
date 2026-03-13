The cleanest integration is to keep Recommendations as a separate feature surface that reuses the same context sources already assembled for chat and insights, rather than embedding recommendation logic directly into the current chat response flow. The main backend plug-in point is [backend/app/rag/pipeline.py](backend/app/rag/pipeline.py), specifically the existing context-building pattern that already pulls emotions, habits, memories, and retrieval context. The existing reusable data sources are [backend/app/models/message_analysis.py](backend/app/models/message_analysis.py), [backend/app/models/user_chat_memory.py](backend/app/models/user_chat_memory.py), [backend/app/analytics/time_patterns.py](backend/app/analytics/time_patterns.py), and [backend/app/services/chat_memory_service.py](backend/app/services/chat_memory_service.py). The structured JSON generation path already exists in [backend/app/services/llm_service.py](backend/app/services/llm_service.py), so recommendation output should be produced through that rather than freeform text.

On the frontend, the new page belongs in the router in [frontend/src/App.tsx](frontend/src/App.tsx) and the sidebar nav in [frontend/src/components/Sidebar.tsx](frontend/src/components/Sidebar.tsx). Backend communication already goes through [frontend/src/services/api.ts](frontend/src/services/api.ts), with global app state in [frontend/src/state/AppStateContext.tsx](frontend/src/state/AppStateContext.tsx). I would not expand initial app bootstrap to load recommendations automatically. Keep recommendations lazy-loaded from the new page so chat and insights startup behavior stays unchanged.

## Plan: Recommendations Page

Add a new user-scoped Recommendations feature that generates structured recommendations from the existing RAG and LLM stack using emotional insights, recent chat summaries, recommendation interaction history, active habits, and a selected category. The recommended architecture is: a dedicated RecommendationService, new persistence for recommendation batches and interactions, a persistent habit-checklist model, a new recommendations API surface, and a new frontend page that sits beside Chat and Insights without changing their current behavior.

**Steps**
1. Define Recommendations as a separate domain, not a chat subfeature. Reuse chat and insights context, but keep recommendation generation and storage behind dedicated services and APIs.
2. Add backend persistence for four concerns: daily recommendation batches, individual recommendation items, recommendation interaction events, and persistent user habits with per-day completion records.
3. Reuse existing models for context only: [backend/app/models/user.py](backend/app/models/user.py), [backend/app/models/conversation.py](backend/app/models/conversation.py), [backend/app/models/message_analysis.py](backend/app/models/message_analysis.py), and [backend/app/models/user_chat_memory.py](backend/app/models/user_chat_memory.py).
4. Introduce new backend models for RecommendationBatch, RecommendationItem, RecommendationInteraction, UserHabit, and UserHabitCheck. RecommendationBatch should represent a generation session for a user and day. RecommendationItem should hold each returned suggestion. RecommendationInteraction should capture analytics events. UserHabit and UserHabitCheck should power the persistent daily checklist.
5. Extend [backend/app/database/schema.py](backend/app/database/schema.py) with additive SQLite-safe schema upgrades for the new tables and indexes.
6. Create a RecommendationService that follows the same dependency-injection pattern used in [backend/app/rag/pipeline.py](backend/app/rag/pipeline.py) and [backend/app/services/chat_memory_service.py](backend/app/services/chat_memory_service.py). It should assemble recommendation context from [backend/app/analytics/time_patterns.py](backend/app/analytics/time_patterns.py), [backend/app/models/message_analysis.py](backend/app/models/message_analysis.py), [backend/app/models/user_chat_memory.py](backend/app/models/user_chat_memory.py), active habits, and prior recommendation interactions.
7. Generate recommendations through [backend/app/services/llm_service.py](backend/app/services/llm_service.py) using structured JSON output. The prompt should require stable fields such as category, recommendation kind, title, rationale, action payload, estimated duration, and follow-up text.
8. Use the existing retrieval stack from [backend/app/rag/pipeline.py](backend/app/rag/pipeline.py) and the vector layer as supporting context for recommendation grounding, but keep chat generation unchanged. Retrieval should enrich the recommendation prompt, not replace it.
9. Add a recommendations router following the same user-scoped endpoint pattern as [backend/app/api/insights.py](backend/app/api/insights.py), then register it in [backend/app/api/routes.py](backend/app/api/routes.py).
10. Add endpoints for: loading today’s batch, generating a batch for a category, loading history, selecting a recommendation, completing a recommendation, retrying or regenerating, logging interactions, converting a habit recommendation into a persistent habit, loading the daily habit checklist, and checking or unchecking habits for a date.
11. Support both generation modes you selected: manual generation from the Recommendations page and optional post-chat refresh. The post-chat hook should run after chat completion, but it should call RecommendationService separately so existing chat persistence and streaming behavior remain isolated.
12. Keep daily refresh batch-based. When the user opens the page, load today’s batch if it exists; otherwise generate one. If they regenerate on the same day, keep the old batch in history and mark one batch as active for that date.
13. Treat each recommendation kind differently:
    Timed action: client starts a timer, logs timer_started, and logs timer_completed on finish.
    Habit: accepting it creates or activates a persistent user habit and moves it into the daily checklist.
    Instant action: selection can be followed by immediate completion.
    Reflection: selecting it routes into the existing chat flow so the response is stored in conversations and messages, not a new reflection store.
14. Add a new Recommendations page and route in [frontend/src/App.tsx](frontend/src/App.tsx), plus a new nav item in [frontend/src/components/Sidebar.tsx](frontend/src/components/Sidebar.tsx).
15. Keep recommendations page state page-local at first instead of loading it during app initialization in [frontend/src/state/AppStateContext.tsx](frontend/src/state/AppStateContext.tsx). If shared state is later needed, add a dedicated recommendations slice with its own loading and error state rather than expanding the single global error path.
16. Extend [frontend/src/types/api.ts](frontend/src/types/api.ts) with recommendation batch, recommendation item, interaction, generation request, persistent habit, and daily checklist types.
17. Add recommendation and habit client methods to [frontend/src/services/api.ts](frontend/src/services/api.ts), following the existing insights and conversations request pattern.
18. Build the Recommendations page from focused components: category selector, recommendation list, item action panel, timed-action timer, persistent daily checklist, and recommendation history.
19. Adjust the layout logic in [frontend/src/App.tsx](frontend/src/App.tsx) so route-specific layout is not hardcoded only around chat. Keep the chat insights rail chat-only unless a later design explicitly wants recommendation-side insights.
20. Add tests for user scoping, structured JSON validation, history retention, interaction logging, habit conversion and daily completion behavior, reflection routing into chat, and non-regression of existing chat and insights flows.

**New frontend pieces**
1. A Recommendations page component using [frontend/src/components/InsightsDashboard.tsx](frontend/src/components/InsightsDashboard.tsx) as the closest layout and fetch-pattern reference.
2. A category picker for recommendation generation.
3. A recommendation card list with per-kind actions.
4. A timed-action panel or timer widget.
5. A persistent daily habit checklist panel.
6. A history view for previous daily batches.

**Backend services**
1. A RecommendationService for context assembly, retrieval enrichment, prompt building, JSON validation, persistence, and freshness rules.
2. A small habit-tracking service or habit methods within RecommendationService for converting recommendation items into active habits and recording daily completion.
3. A lightweight interaction logging path so recommendation events become future RAG context.

**API surface**
1. A recommendations router parallel to [backend/app/api/insights.py](backend/app/api/insights.py).
2. Endpoints for daily batch retrieval and generation.
3. Endpoints for recommendation selection, completion, retry, and interaction logging.
4. Endpoints for persistent daily habit checklist retrieval and habit check or uncheck.

**How it fits without breaking current behavior**
The key boundary is separation. Chat continues to use [backend/app/rag/pipeline.py](backend/app/rag/pipeline.py) for conversation generation and persistence. Insights continue to read from [backend/app/analytics/time_patterns.py](backend/app/analytics/time_patterns.py) through [backend/app/api/insights.py](backend/app/api/insights.py). Recommendations become a new consumer of those same context sources, with their own storage and endpoints. On the frontend, the new page becomes an additional route beside Chat and Insights, while keeping the existing startup path and chat streaming flow intact.

I could not persist the plan to session memory because the environment returned a no-space-left-on-device error during the write attempt.

1. Approve this plan and I’ll leave it ready for implementation handoff.
2. Tell me what to change if you want a different schema split, endpoint shape, or page behavior.
3. If you want, I can also turn this into a shorter engineering spec with exact request and response contracts before implementation.
