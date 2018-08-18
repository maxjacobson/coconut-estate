-- Your SQL goes here
create table users (
  id serial primary key not null,
  name character varying(256) not null,
  email character varying(256) not null,
  password_hash character varying(256) not null,
  created_at timestamp not null default now(),
  updated_at timestamp not null default now()
);

select diesel_manage_updated_at('users');
create unique index name on users (email);
