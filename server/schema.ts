import { real, sqliteTable, text } from "drizzle-orm/sqlite-core";

export const treasurePoints = sqliteTable("treasure_points", {
  id: text("id").primaryKey(),
  name: text("name").notNull(),
  description: text("description").notNull(),
  latitude: real("latitude").notNull(),
  longitude: real("longitude").notNull(),
  qrCode: text("qr_code").notNull(),
});

export const timetableEvents = sqliteTable("timetable_events", {
  id: text("id").primaryKey(),
  title: text("title").notNull(),
  description: text("description").notNull(),
  startTime: text("start_time").notNull(),
  endTime: text("end_time").notNull(),
  location: text("location").notNull(),
  imageUrl: text("image_url"),
  tags: text("tags", { mode: "json" }).notNull().$type<string[]>(),
});

export type TreasurePoint = typeof treasurePoints.$inferSelect;
export type TimetableEvent = typeof timetableEvents.$inferSelect;
