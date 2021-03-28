/*
 Navicat Premium Data Transfer

 Source Server         : localhost_5432
 Source Server Type    : PostgreSQL
 Source Server Version : 120002
 Source Host           : localhost:5432
 Source Catalog        : socket_chart
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 120002
 File Encoding         : 65001

 Date: 29/03/2021 00:22:15
*/


-- ----------------------------
-- Sequence structure for sc_room_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sc_room_id_seq";
CREATE SEQUENCE "public"."sc_room_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for sc_user_room_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."sc_user_room_id_seq";
CREATE SEQUENCE "public"."sc_user_room_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Sequence structure for user_id_seq
-- ----------------------------
DROP SEQUENCE IF EXISTS "public"."user_id_seq";
CREATE SEQUENCE "public"."user_id_seq" 
INCREMENT 1
MINVALUE  1
MAXVALUE 2147483647
START 1
CACHE 1;

-- ----------------------------
-- Table structure for sc_room
-- ----------------------------
DROP TABLE IF EXISTS "public"."sc_room";
CREATE TABLE "public"."sc_room" (
  "id" int4 NOT NULL DEFAULT nextval('sc_room_id_seq'::regclass),
  "description" varchar(255) COLLATE "pg_catalog"."default",
  "create_time" timestamp(6) NOT NULL DEFAULT now(),
  "name" varchar(255) COLLATE "pg_catalog"."default" NOT NULL
)
;
COMMENT ON COLUMN "public"."sc_room"."description" IS '描述';
COMMENT ON COLUMN "public"."sc_room"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sc_room"."name" IS '房间名';

-- ----------------------------
-- Table structure for sc_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."sc_user";
CREATE TABLE "public"."sc_user" (
  "id" int4 NOT NULL DEFAULT nextval('user_id_seq'::regclass),
  "username" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "password" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "create_time" timestamp(6) NOT NULL DEFAULT now()
)
;
COMMENT ON COLUMN "public"."sc_user"."username" IS '用户名';
COMMENT ON COLUMN "public"."sc_user"."password" IS '密码';

-- ----------------------------
-- Table structure for sc_user_room
-- ----------------------------
DROP TABLE IF EXISTS "public"."sc_user_room";
CREATE TABLE "public"."sc_user_room" (
  "id" int4 NOT NULL DEFAULT nextval('sc_user_room_id_seq'::regclass),
  "user_id" int4 NOT NULL,
  "room_id" int4 NOT NULL
)
;

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sc_room_id_seq"
OWNED BY "public"."sc_room"."id";
SELECT setval('"public"."sc_room_id_seq"', 32, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."sc_user_room_id_seq"
OWNED BY "public"."sc_user_room"."id";
SELECT setval('"public"."sc_user_room_id_seq"', 27, true);

-- ----------------------------
-- Alter sequences owned by
-- ----------------------------
ALTER SEQUENCE "public"."user_id_seq"
OWNED BY "public"."sc_user"."id";
SELECT setval('"public"."user_id_seq"', 14, true);

-- ----------------------------
-- Indexes structure for table sc_room
-- ----------------------------
CREATE UNIQUE INDEX "sc_room_name_idx" ON "public"."sc_room" USING btree (
  "name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sc_room
-- ----------------------------
ALTER TABLE "public"."sc_room" ADD CONSTRAINT "sc_room_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Indexes structure for table sc_user
-- ----------------------------
CREATE UNIQUE INDEX "user_username_idx" ON "public"."sc_user" USING btree (
  "username" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
);

-- ----------------------------
-- Primary Key structure for table sc_user
-- ----------------------------
ALTER TABLE "public"."sc_user" ADD CONSTRAINT "user_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Primary Key structure for table sc_user_room
-- ----------------------------
ALTER TABLE "public"."sc_user_room" ADD CONSTRAINT "sc_user_room_pkey" PRIMARY KEY ("id");

-- ----------------------------
-- Foreign Keys structure for table sc_user_room
-- ----------------------------
ALTER TABLE "public"."sc_user_room" ADD CONSTRAINT "sc_user_room_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "public"."sc_room" ("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "public"."sc_user_room" ADD CONSTRAINT "sc_user_room_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."sc_user" ("id") ON DELETE CASCADE ON UPDATE CASCADE;
