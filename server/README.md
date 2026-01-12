# SGGW Days API Server

Bun.js-based REST API server for managing SGGW Days app data.

## Technology Stack

- **Bun.js**: JavaScript runtime and package manager
- **Drizzle ORM**: Type-safe SQL ORM for database operations
- **SQLite**: Lightweight database for treasure points and timetable events
- **Markdown Files**: Individual `.md` files for wiki articles with YAML frontmatter

## Storage

- **SQLite Database**: `data/sggw_days.db` - Stores treasure points and timetable events using Drizzle ORM
- **Markdown Files**: `data/wiki_articles/` - Each article is a separate .md file with YAML frontmatter

## Setup

```bash
cd server
bun install
```

Database will be automatically created and migrated on first server run.

## Database Migrations

The project uses **Drizzle Kit** for type-safe schema migrations.

### Generate Migration Files

After modifying [schema.ts](schema.ts), generate migration SQL:

```bash
bun run db:generate
```

This creates a new migration file in `drizzle/` directory.

### Apply Migrations

Migrations are **automatically applied** when the server starts via `migrate()` in [database.ts](database.ts).

For manual migration:

```bash
bun run db:migrate
```

### Push Schema Directly (Development)

Skip migration files and push schema changes directly to database:

```bash
bun run db:push
```

⚠️ **Warning**: This bypasses migration history. Use only in development.

### Drizzle Studio

Launch visual database browser:

```bash
bun run db:studio
```

Opens at http://localhost:4983

## Running

```bash
# Production
bun start

# Development (with auto-reload)
bun run dev
```

Server runs on `http://localhost:3000`

## API Endpoints

### GET Endpoints

- `GET /treasure_points.json` - Get all treasure hunt points
- `GET /wiki_articles.json` - Get all wiki articles
- `GET /timetable_events.json` - Get all timetable events

### POST Endpoints (Admin)

- `POST /treasure_points` - Create new treasure point
- `POST /wiki_articles` - Create new wiki article
- `POST /timetable_events` - Create new timetable event

### PUT Endpoints (Admin)

- `PUT /treasure_points/:id` - Update treasure point
- `PUT /wiki_articles/:id` - Update wiki article
- `PUT /timetable_events/:id` - Update timetable event

### DELETE Endpoints (Admin)

- `DELETE /treasure_points/:id` - Delete treasure point
- `DELETE /wiki_articles/:id` - Delete wiki article
- `DELETE /timetable_events/:id` - Delete timetable event

## Data Format

### Wiki Articles (Markdown)

Each article is stored as a `.md` file with YAML frontmatter:

```markdown
---
title: About SGGW
category: University
imageUrl: null
tags: history, about
---

# Warsaw University of Life Sciences (SGGW)

Your markdown content here...
```

### Database Schema (Drizzle ORM)

**Treasure Points:**

```typescript
export const treasurePoints = sqliteTable("treasure_points", {
  id: text("id").primaryKey(),
  name: text("name").notNull(),
  description: text("description").notNull(),
  latitude: real("latitude").notNull(),
  longitude: real("longitude").notNull(),
  qrCode: text("qr_code").notNull(),
});
```

**Timetable Events:**

```typescript
export const timetableEvents = sqliteTable("timetable_events", {
  id: text("id").primaryKey(),
  title: text("title").notNull(),
  description: text("description").notNull(),
  startTime: text("start_time").notNull(),
  endTime: text("end_time").notNull(),
  location: text("location").notNull(),
  imageUrl: text("image_url"),
  tags: text("tags").notNull(),
});
```

### Example Queries

**Select all treasure points:**

```typescript
const points = await db.select().from(treasurePoints);
```

**Insert a new event:**

```typescript
await db.insert(timetableEvents).values({
  id: crypto.randomUUID(),
  title: "Event Name",
  // ... other fields
});
```

**Update a point:**

```typescript
await db
  .update(treasurePoints)
  .set({ name: "New Name" })
  .where(eq(treasurePoints.id, pointId));
```

**Delete an event:**

```typescript
await db.delete(timetableEvents).where(eq(timetableEvents.id, eventId));
```
