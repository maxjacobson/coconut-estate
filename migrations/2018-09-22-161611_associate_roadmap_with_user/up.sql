-- Your SQL goes here

-- dropping data because there's nothing important there yet, and existing
-- roadmaps don't have a reference to their author yet
delete from roadmaps;

alter table roadmaps
  add column author_id integer not null;

create index "index_roadmaps_on_author_id"
  on roadmaps using btree (author_id);

alter table only roadmaps
  add constraint roadmaps_must_have_an_author
  foreign key (author_id) references users(id);
