# Backend (Express + PostgreSQL)

## Environment
Copy `.env.example` to `.env`.

## Scripts
- `npm run dev` - run server with watch
- `npm start` - run server

## SQL
- `sql/schema.sql` creates prototype tables
- `sql/seed.sql` inserts starter data

## Design Notes
- `USE_MOCK_DATA=true` routes requests through in-memory placeholder data for rapid prototyping.
- Set `USE_MOCK_DATA=false` to use Postgres with the same route/controller/service interfaces.
- Routes are separated into auth/content/training/task-board domains for maintainability.
