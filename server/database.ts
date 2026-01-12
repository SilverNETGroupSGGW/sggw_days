import { drizzle } from "drizzle-orm/bun-sqlite";
import { migrate } from "drizzle-orm/bun-sqlite/migrator";
import { join } from "node:path";
import * as schema from "./schema";

const DATA_DIR = join(import.meta.dir, "data");
const DB_PATH = join(DATA_DIR, "sggw_days.db");

export function initDatabase() {
  const db = drizzle(DB_PATH, { schema });

  // Run migrations automatically
  migrate(db, { migrationsFolder: "./drizzle" });

  return db;
}

export function getDatabase() {
  return drizzle(DB_PATH, { schema });
}
