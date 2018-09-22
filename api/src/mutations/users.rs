use diesel::dsl::insert_into;
use diesel::prelude::{ExpressionMethods, QueryDsl, RunQueryDsl};
use diesel::result::Error;
use diesel::update as diesel_update;
use diesel::PgConnection;
use libpasta;

use database;
use database_schema::users;
use graphql;

pub fn create(
    email: String,
    password: String,
    username: String,
    connection: &PgConnection,
) -> Result<graphql::User, Error> {
    debug!(
        "Attempting to insert a user with username: {}, email: {}",
        username, email
    );

    let password_hash = libpasta::hash_password(&password);

    let user: database::User = insert_into(users::table)
        .values((
            users::email.eq(email),
            users::password_hash.eq(password_hash),
            users::username.eq(username),
        )).get_result(connection)?;

    Ok(user.into())
}

// Note: right now I only care to update passwords, but we may want to support updating other stuff
// later, which will require a more thoughtful implementation.
pub fn update(
    user_id: i32,
    password: Option<String>,
    connection: &PgConnection,
) -> Result<graphql::User, Error> {
    debug!("Attempting to update user with id {}", user_id);

    let user: database::User = match password {
        Some(password) => {
            let password_hash = libpasta::hash_password(&password);
            let target = users::table.filter(users::id.eq(user_id));

            diesel_update(target)
                .set(users::password_hash.eq(password_hash))
                .get_result(connection)?
        }
        None => database::User::find(user_id, connection)?,
    };

    Ok(user.into())
}
