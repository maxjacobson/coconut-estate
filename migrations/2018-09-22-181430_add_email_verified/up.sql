-- Your SQL goes here
alter table users
  add column email_verified boolean default false not null;
