CREATE TABLE `timetable_events` (
	`id` text PRIMARY KEY NOT NULL,
	`title` text NOT NULL,
	`description` text NOT NULL,
	`start_time` text NOT NULL,
	`end_time` text NOT NULL,
	`location` text NOT NULL,
	`image_url` text,
	`tags` text NOT NULL
);
--> statement-breakpoint
CREATE TABLE `treasure_points` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`description` text NOT NULL,
	`latitude` real NOT NULL,
	`longitude` real NOT NULL,
	`qr_code` text NOT NULL,
	`points` integer DEFAULT 10 NOT NULL
);
