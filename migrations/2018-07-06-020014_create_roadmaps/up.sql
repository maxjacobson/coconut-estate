-- Your SQL goes here
create table roadmaps (
  id serial primary key not null,
  name character varying(256) not null,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now()
);
