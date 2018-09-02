use diesel::dsl::insert_into;
use diesel::prelude::{ExpressionMethods, RunQueryDsl};
use diesel::result::Error;
use diesel::PgConnection;

use database;
use database_schema::roadmaps;
use graphql;

pub fn create(name: String, connection: &PgConnection) -> Result<graphql::Roadmap, Error> {
    debug!("Attempting to insert a roadmap with name: {}", name);

    let roadmap: database::Roadmap = insert_into(roadmaps::table)
        .values(roadmaps::name.eq(&name))
        .get_result(connection)?;

    Ok(roadmap.into())
}
