-- This file should undo anything in `up.sql`
alter table users
  drop column if exists site_admin;
