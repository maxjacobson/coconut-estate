use diesel::result::Error;
use diesel::PgConnection;
use libpasta;
use std::convert::From;
use std::fmt;

use database;
use graphql;

pub enum CreateSignInFailure {
    Database(Error),
    NoMatch,
}

impl fmt::Display for CreateSignInFailure {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            CreateSignInFailure::Database(e) => write!(f, "{}", e),
            CreateSignInFailure::NoMatch => write!(f, "Username/Email does not match password"),
        }
    }
}

impl From<Error> for CreateSignInFailure {
    fn from(e: Error) -> CreateSignInFailure {
        CreateSignInFailure::Database(e)
    }
}

pub fn create(
    email_or_username: String,
    password: String,
    connection: &PgConnection,
    jwt_secret: &str,
) -> Result<graphql::SignIn, CreateSignInFailure> {
    debug!("Attempting to sign in as {}", email_or_username);

    if let Some(user) = database::User::load_from_email_or_username(&email_or_username, connection)?
    {
        if libpasta::verify_password(&user.password_hash, &password) {
            let token = user.generate_token(jwt_secret);

            Ok(graphql::SignIn { token })
        } else {
            debug!("{} provided a bad password", email_or_username);
            Err(CreateSignInFailure::NoMatch)
        }
    } else {
        debug!("{} did not match a user in the database", email_or_username);
        Err(CreateSignInFailure::NoMatch)
    }
}
