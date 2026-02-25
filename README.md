# MTC Cafeteria Prototype (Flutter Web + PERN)

Lightweight prototype focused on organization and clarity for cafeteria workers.

## Stack
- Frontend: Flutter (web)
- Backend: Node.js + Express + PostgreSQL
- Auth: Basic email/password with JWT
- Data mode: Mock-by-default (`USE_MOCK_DATA=true`) for fast prototype startup

## Project Structure
- `frontend_flutter/` Flutter web app (role-based dashboards + landing page)
- `backend/` Express API + PostgreSQL access layer
- `backend/sql/schema.sql` database schema
- `backend/sql/seed.sql` starter data

## Roles
- Employee
- Lead Trainer
- Supervisor
- Student Manager

## Core API (Prototype)
- `POST /api/auth/login`
- `GET /api/content/landing-items`
- `POST /api/content/landing-items` (Student Manager, Supervisor)
- `PUT /api/content/landing-items/:id` (Student Manager, Supervisor)
- `DELETE /api/content/landing-items/:id` (Student Manager, Supervisor)
- `GET /api/trainings` (Lead Trainer, Supervisor, Student Manager)
- `GET /api/task-board`
- `POST /api/task-board/tasks/:taskId/completion`
- `GET /api/supervisor-board`
- `POST /api/supervisor-board/jobs/:jobId/check`
- `GET /api/supervisor-board/jobs/:jobId/tasks`
- `POST /api/supervisor-board/jobs/:jobId/tasks/:taskId/check`
- `POST /api/supervisor-board/reset`
- `GET /api/trainer-board`
- `POST /api/trainer-board/trainees/:traineeUserId/tasks/:taskId/completion`

## Local Run
### 1) Backend
```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

Notes:
- Default `.env.example` uses `USE_MOCK_DATA=true` so you can run without Postgres.
- For Postgres mode, set `USE_MOCK_DATA=false`, create DB, then run schema + seed SQL.

### 2) Flutter Web
```bash
cd frontend_flutter
flutter pub get
flutter run -d chrome
```

Optional API URL override:
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3001
```

## Test Accounts (Mock/Seed)
- `employee@mtc.local` / `password123`
- `trainer@mtc.local` / `password123`
- `supervisor@mtc.local` / `password123`
- `manager@mtc.local` / `password123`

## Scope Guardrails
- No audit logs
- Placeholder scheduling/job/task catalog content only

## TODO Hooks
- Replace mock mode with persistent Postgres-only mode for production
- Add stronger validation and error-handling UX
- Expand shift/job/task authoring interfaces

## Docker Deploy (Server)
This mirrors the Edgy Campers setup: a Docker Compose stack with fixed host ports.

1) First-time setup:
```bash
cd /home/lajicpajam/projects/MTCafeteria
cp .env.example .env
chmod +x deploy_web_stack.sh
```

2) Build frontend + start stack:
```bash
cd /home/lajicpajam/projects/MTCafeteria
./deploy_web_stack.sh
```

3) Update on new commits:
```bash
cd /home/lajicpajam/projects/MTCafeteria
git fetch origin
git checkout main
git reset --hard origin/main
./deploy_web_stack.sh
```

Default exposed ports:
- Frontend: `8086`
- Backend API: `3001`
- Postgres: `5434`

Point your DNS record to the server IP, then browse:
- `http://<your-domain>:8086`
