CREATE TABLE "events" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "type" varchar(255), "created_at" datetime, "updated_at" datetime, "source_player_id" integer, "target_player_id" integer, "period_id" integer);
CREATE TABLE "games" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255), "created_at" datetime, "updated_at" datetime, "state" varchar(255), "invite_only" boolean, "min_players" integer, "period_length" integer, "short_code" varchar(255), "owner_id" integer, "max_players" integer);
CREATE TABLE "invitations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "game_id" integer, "twitter_login" varchar(255), "created_at" datetime, "updated_at" datetime, "invited_by_id" integer);
CREATE TABLE "messages" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "game_id" integer, "text" varchar(255), "delivered_at" datetime, "created_at" datetime, "updated_at" datetime, "type" varchar(255), "from_user_id" integer, "to_user_id" integer, "status_id" integer);
CREATE TABLE "periods" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "game_id" integer, "created_at" datetime, "updated_at" datetime);
CREATE TABLE "players" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer, "game_id" integer, "type" varchar(255), "created_at" datetime, "updated_at" datetime, "dead" boolean DEFAULT 'f');
CREATE TABLE "schema_migrations" ("version" varchar(255) NOT NULL);
CREATE TABLE "users" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "twitter_id" varchar(255), "login" varchar(255), "access_token" varchar(255), "access_secret" varchar(255), "remember_token" varchar(255), "remember_token_expires_at" datetime, "name" varchar(255), "location" varchar(255), "description" varchar(255), "profile_image_url" varchar(255), "url" varchar(255), "protected" boolean, "profile_background_color" varchar(255), "profile_sidebar_fill_color" varchar(255), "profile_link_color" varchar(255), "profile_sidebar_border_color" varchar(255), "profile_text_color" varchar(255), "profile_background_image_url" varchar(255), "profile_background_tiled" boolean, "friends_count" integer, "statuses_count" integer, "followers_count" integer, "favourites_count" integer, "utc_offset" integer, "time_zone" varchar(255), "created_at" datetime, "updated_at" datetime);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
INSERT INTO schema_migrations (version) VALUES ('20090612204231');

INSERT INTO schema_migrations (version) VALUES ('20090613160919');

INSERT INTO schema_migrations (version) VALUES ('20090613172347');

INSERT INTO schema_migrations (version) VALUES ('20090613190422');

INSERT INTO schema_migrations (version) VALUES ('20090613201557');

INSERT INTO schema_migrations (version) VALUES ('20090615155239');

INSERT INTO schema_migrations (version) VALUES ('20090616202655');

INSERT INTO schema_migrations (version) VALUES ('20090621215112');

INSERT INTO schema_migrations (version) VALUES ('20090622143525');

INSERT INTO schema_migrations (version) VALUES ('20090622183349');

INSERT INTO schema_migrations (version) VALUES ('20090715195550');

INSERT INTO schema_migrations (version) VALUES ('20090717211316');

INSERT INTO schema_migrations (version) VALUES ('20090720234620');

INSERT INTO schema_migrations (version) VALUES ('20090721012532');