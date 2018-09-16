-- This file should undo anything in `up.sql`
alter table users add column name character varying(256);
