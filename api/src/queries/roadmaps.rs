use diesel::result::Error;
use diesel::PgConnection;
use log::debug;

use crate::database;
use crate::graphql::Roadmap;

pub fn find(id: i32, connection: &PgConnection) -> Result<Roadmap, Error> {
    debug!("Looking up roadmap with id {}", id);

    let roadmap = database::Roadmap::find(id, connection)?;
    Ok(roadmap.into())
}

pub fn all(connection: &PgConnection) -> Result<Vec<Roadmap>, Error> {
    debug!("Loading all roadmaps");

    let roadmaps = database::Roadmap::all(connection)?;
    Ok(roadmaps.iter().map(|roadmap| roadmap.into()).collect())
}
