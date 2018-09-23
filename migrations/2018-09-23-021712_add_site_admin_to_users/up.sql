-- Your SQL goes here
alter table users
  add column site_admin bool default false not null;
