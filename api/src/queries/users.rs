use diesel::result::Error;
use diesel::PgConnection;
use log::debug;

use crate::database;
use crate::graphql::User;

pub fn find(id: i32, connection: &PgConnection) -> Result<User, Error> {
    debug!("Attempting to look up current user");

    let user = database::User::find(id, connection)?;
    Ok(user.into())
}

pub fn all(connection: &PgConnection) -> Result<Vec<User>, Error> {
    debug!("Attempting to look up all users");

    let users = database::User::all(connection)?;
    Ok(users.iter().map(|user| user.into()).collect())
}
