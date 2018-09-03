use chrono::NaiveDateTime;
use diesel::prelude::{PgConnection, QueryDsl, RunQueryDsl};
use diesel::result::Error;

use database_schema;

#[derive(Clone, Debug, Queryable, Serialize)]
pub struct Roadmap {
    pub id: i32,
    pub name: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

impl Roadmap {
    pub fn find(id: i32, connection: &PgConnection) -> Result<Self, Error> {
        database_schema::roadmaps::table
            .find(id)
            .get_result(connection)
    }

    pub fn all(connection: &PgConnection) -> Result<Vec<Self>, Error> {
        database_schema::roadmaps::table.load(connection)
    }
}