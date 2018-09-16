-- This file should undo anything in `up.sql`
alter table users alter column name set not null;
