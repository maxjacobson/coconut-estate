use diesel::dsl::insert_into;
use diesel::prelude::{ExpressionMethods, RunQueryDsl};
use diesel::result::Error;
use diesel::PgConnection;
use log::debug;

use crate::database;
use crate::database_schema::roadmaps;
use crate::graphql;

pub fn create(
    name: String,
    author_id: i32,
    connection: &PgConnection,
) -> Result<graphql::Roadmap, Error> {
    debug!("Attempting to insert a roadmap with name: {}", name);

    let roadmap: database::Roadmap = insert_into(roadmaps::table)
        .values((roadmaps::name.eq(&name), roadmaps::author_id.eq(author_id)))
        .get_result(connection)?;

    Ok(roadmap.into())
}
