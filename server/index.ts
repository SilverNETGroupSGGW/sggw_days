import { eq } from "drizzle-orm";
import { initDatabase } from "./database";
import { timetableEvents, treasurePoints } from "./schema";
import type {
  CreateTimetableEventRequest,
  CreateTreasurePointRequest,
  CreateWikiArticleRequest,
} from "./types";
import {
  createWikiArticle,
  deleteWikiArticle,
  getWikiArticle,
  listWikiArticles,
  updateWikiArticle,
} from "./wiki";

const PORT = process.env.PORT || 3000;

// Initialize database
const db = initDatabase();

// CORS headers for local development
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type",
} as const;

// Helper functions for responses with CORS headers
const jsonResponse = (data: unknown, status = 200) =>
  Response.json(data, { headers: corsHeaders, status });

const emptyResponse = (status = 204) =>
  new Response(null, { status, headers: corsHeaders });

const errorResponse = (message: string, status = 500) =>
  new Response(message, { status, headers: corsHeaders });

// Main server
const server = Bun.serve({
  port: PORT,
  async fetch(req) {
    const url = new URL(req.url);
    const path = url.pathname;
    const method = req.method;

    // Handle CORS preflight
    if (method === "OPTIONS") {
      return emptyResponse(200);
    }

    try {
      // GET endpoints
      if (method === "GET") {
        // Treasure Points
        if (path === "/treasure_points.json") {
          const points = await db.select().from(treasurePoints);
          return jsonResponse(points);
        }

        // Wiki Articles
        if (path === "/wiki_articles.json") {
          const articles = await listWikiArticles();
          return jsonResponse(articles);
        }

        // Timetable Events
        if (path === "/timetable_events.json") {
          const events = await db.select().from(timetableEvents);
          return jsonResponse(events);
        }
      }

      // POST endpoints - create new items
      if (method === "POST") {
        const body = await req.json();

        // Treasure Points
        if (path === "/treasure_points") {
          const data = body as CreateTreasurePointRequest;
          const id = crypto.randomUUID();

          await db.insert(treasurePoints).values({ id, ...data });
          return jsonResponse({ id, ...data }, 201);
        }

        // Wiki Articles
        if (path === "/wiki_articles") {
          const data = body as CreateWikiArticleRequest;
          const article = await createWikiArticle({
            title: data.title,
            content: data.content,
            category: data.category,
            imageUrl: data.imageUrl ?? null,
            tags: data.tags ?? [],
          });
          return jsonResponse(article, 201);
        }

        // Timetable Events
        if (path === "/timetable_events") {
          const data = body as CreateTimetableEventRequest;
          const id = crypto.randomUUID();

          await db.insert(timetableEvents).values({
            id,
            ...data,
            imageUrl: data.imageUrl ?? null,
            tags: data.tags ?? [],
          });

          return jsonResponse(
            {
              id,
              ...data,
              imageUrl: data.imageUrl ?? null,
              tags: data.tags ?? [],
            },
            201
          );
        }
      }

      // PUT endpoints - update existing items
      if (method === "PUT") {
        const body = await req.json();
        const match = path.match(
          /\/(treasure_points|wiki_articles|timetable_events)\/(.+)/
        );

        if (match) {
          const [, resource, id] = match;

          // Treasure Points
          if (resource === "treasure_points") {
            const data = body as CreateTreasurePointRequest;

            await db
              .update(treasurePoints)
              .set(data)
              .where(eq(treasurePoints.id, id));

            return jsonResponse({ id, ...data });
          }

          // Wiki Articles
          if (resource === "wiki_articles") {
            const data = body as CreateWikiArticleRequest;
            const existing = await getWikiArticle(id);

            if (!existing) {
              return errorResponse("Not found", 404);
            }

            await updateWikiArticle({
              id,
              ...data,
              imageUrl: data.imageUrl ?? null,
              tags: data.tags ?? [],
            });

            return jsonResponse({
              id,
              ...data,
              imageUrl: data.imageUrl ?? null,
              tags: data.tags ?? [],
            });
          }

          // Timetable Events
          if (resource === "timetable_events") {
            const data = body as CreateTimetableEventRequest;

            await db
              .update(timetableEvents)
              .set({
                ...data,
                imageUrl: data.imageUrl ?? null,
                tags: data.tags ?? [],
              })
              .where(eq(timetableEvents.id, id));

            return jsonResponse({
              id,
              ...data,
              imageUrl: data.imageUrl ?? null,
              tags: data.tags ?? [],
            });
          }
        }
      }

      // DELETE endpoints - remove items
      if (method === "DELETE") {
        const match = path.match(
          /\/(treasure_points|wiki_articles|timetable_events)\/(.+)/
        );

        if (match) {
          const [, resource, id] = match;

          // Treasure Points
          if (resource === "treasure_points") {
            await db.delete(treasurePoints).where(eq(treasurePoints.id, id));
            return emptyResponse();
          }

          // Wiki Articles
          if (resource === "wiki_articles") {
            const deleted = await deleteWikiArticle(id);
            if (!deleted) {
              return errorResponse("Not found", 404);
            }
            return emptyResponse();
          }

          // Timetable Events
          if (resource === "timetable_events") {
            await db.delete(timetableEvents).where(eq(timetableEvents.id, id));
            return emptyResponse();
          }
        }
      }

      return errorResponse("Not found", 404);
    } catch (error) {
      console.error("Error:", error);
      return errorResponse("Internal server error");
    }
  },
});

console.log(`🚀 SGGW Days API running at http://localhost:${server.port}`);
console.log(`📊 Using SQLite with Drizzle ORM: data/sggw_days.db`);
console.log(`📝 Wiki articles stored in: data/wiki_articles/`);
