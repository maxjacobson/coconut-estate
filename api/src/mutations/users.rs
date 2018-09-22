use diesel::dsl::insert_into;
use diesel::prelude::{ExpressionMethods, RunQueryDsl};
use diesel::result::Error;
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
