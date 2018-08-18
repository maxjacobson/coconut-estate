-- Your SQL goes here

--- Nothing important there yet, and this should be "not null"
delete from users;

alter table users
  add column username character varying(256) not null;

create unique index username on users (username);
