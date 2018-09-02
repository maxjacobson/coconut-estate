use diesel::result::Error;
use diesel::PgConnection;

use database;
use graphql::User;

pub fn find(id: i32, connection: &PgConnection) -> Result<User, Error> {
    debug!("Attempting to look up current user");

    let user = database::User::find(id, connection)?;
    Ok(user.into())
}
