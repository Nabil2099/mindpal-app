# MindPal Frontend

A calm, minimal reflection interface for the MindPal FastAPI backend.

## Stack

- React + Vite + TypeScript
- Tailwind CSS
- React Router
- Axios
- Recharts

## Run Locally

1. Install dependencies:

```bash
npm install
```

2. Configure API base URL:

```bash
# Windows PowerShell
Copy-Item .env.example .env
# macOS/Linux
cp .env.example .env
```

`VITE_API_BASE_URL` defaults to `http://localhost:8000`.

3. Start the app:

```bash
npm run dev
```

4. Build for production:

```bash
npm run build
```

5. Preview production build:

```bash
npm run preview
```

## Main Screens

- `/chat`: reflection chat with conversation sidebar
- `/insights`: emotion, habit, and time-pattern charts

## Backend Requirements

Run backend at `http://localhost:8000` with these endpoints available:

- `POST /chat`
- `GET /conversations`
- `POST /conversations`
- `DELETE /conversations/{id}`
- `GET /conversations/{id}/messages`
- `GET /insights/emotions`
- `GET /insights/habits`
- `GET /insights/time`

## Safety Notes

- Do not commit `.env` files; only commit `.env.example`.
- Keep API base URLs environment-specific (`VITE_API_BASE_URL`) instead of hardcoding.
- Treat all rendered text as untrusted user content and keep escaping/sanitization defaults intact.
