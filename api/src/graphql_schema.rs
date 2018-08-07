use chrono::NaiveDateTime;
use diesel::prelude::*;
use juniper::FieldResult;
use juniper::RootNode;
use std::env;

use models;

#[derive(GraphQLObject)]
#[graphql(description = "A plan to follow")]
struct Roadmap {
    created_at: NaiveDateTime,
    id: i32,
    name: String,
    updated_at: NaiveDateTime,
}

pub struct QueryRoot;

graphql_object!(QueryRoot: () |&self| {
    field roadmap(&executor, id: i32) -> FieldResult<Roadmap> {
        let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
        let conn = PgConnection::establish(&database_url)
            .expect(&format!("Error connecting to {}", database_url));

        debug!("Looking up roadmap with id {}", id);
        debug!("Executor context looks like: {:#?}", executor.context());

        let query_id = id;

        let roadmap: models::Roadmap = {
            use database_schema::roadmaps::dsl::*;

            roadmaps.filter(id.eq(query_id)).first(&conn)?
        };

        Ok(Roadmap{
            created_at: roadmap.created_at,
            id: roadmap.id,
            name: roadmap.name,
            updated_at: roadmap.updated_at,
        })
    }

    field roadmaps(&executor) -> FieldResult<Vec<Roadmap>> {
        // TODO: consider moving as much code as possible out of macros so rustfmt can be more sure
        // how to reformat it
        let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
        let conn = PgConnection::establish(&database_url)
            .expect(&format!("Error connecting to {}", database_url));

        let roadmaps: Vec<models::Roadmap> = {
            use database_schema::roadmaps::dsl::*;

            roadmaps.load(&conn)?
        };

        Ok(roadmaps.iter().map(|roadmap| Roadmap {
            created_at: roadmap.created_at,
            id: roadmap.id,
            name: roadmap.name.clone(),
            updated_at: roadmap.updated_at,
        }).collect())
    }
});

pub struct MutationRoot;

graphql_object!(MutationRoot: () |&self| {
    field createRoadmap(&executor, name: String) -> FieldResult<Roadmap> {
        debug!("Attempting to insert a roadmap with name: {}", name);
        debug!("Executor context looks like: {:#?}", executor.context());

        let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
        let conn = PgConnection::establish(&database_url)
            .expect(&format!("Error connecting to {}", database_url));

        let provided_name = name;
        let roadmap: models::Roadmap = {
            use database_schema::roadmaps::dsl::*;
            use diesel::dsl::insert_into;

            insert_into(roadmaps).values(name.eq(&provided_name)).get_result(&conn)?
        };


        Ok(Roadmap{
            created_at: roadmap.created_at,
            id: roadmap.id,
            name: roadmap.name,
            updated_at: roadmap.updated_at,
        })
    }
});

pub type Schema = RootNode<'static, QueryRoot, MutationRoot>;

pub fn create_schema() -> Schema {
    Schema::new(QueryRoot {}, MutationRoot {})
}
