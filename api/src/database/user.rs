use chrono::NaiveDateTime;
use diesel::prelude::{ExpressionMethods, PgConnection, QueryDsl, QueryResult, RunQueryDsl};
use diesel::result::Error;
use diesel::BoolExpressionMethods;
use jsonwebtoken;

use auth::Claims;
use database_schema;

#[derive(Clone, Debug, Queryable, Serialize)]
pub struct User {
    pub id: i32,
    pub email: String,
    pub password_hash: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
    pub username: String,
    pub email_verified: bool,
    pub site_admin: bool,
}

impl User {
    pub fn find(id: i32, connection: &PgConnection) -> Result<Self, Error> {
        database_schema::users::table
            .find(id)
            .get_result(connection)
    }

    pub fn all(connection: &PgConnection) -> Result<Vec<Self>, Error> {
        database_schema::users::table.load(connection)
    }

    pub fn load_from_email_or_username(
        email_or_username: &str,
        connection: &PgConnection,
    ) -> Result<Option<Self>, Error> {
        use database_schema::users;

        let user: QueryResult<User> = users::table
            .filter(
                users::email
                    .eq(email_or_username)
                    .or(users::username.eq(email_or_username)),
            ).first(connection);

        match user {
            Ok(user) => Ok(Some(user)),
            Err(Error::NotFound) => Ok(None),
            Err(e) => Err(e),
        }
    }

    pub fn generate_token(&self, secret: &str) -> String {
        let my_claims = Claims {
            id: self.id,
            site_admin: self.site_admin,
        };

        jsonwebtoken::encode(
            &jsonwebtoken::Header::default(),
            &my_claims,
            secret.as_ref(),
        ).unwrap()
    }
}
