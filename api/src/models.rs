use chrono::NaiveDateTime;
use diesel::prelude::{ExpressionMethods, PgConnection, QueryDsl, QueryResult, RunQueryDsl};
use diesel::result::Error as DieselError;
use diesel::BoolExpressionMethods;

#[derive(Clone, Debug, Queryable, Serialize)]
pub struct Roadmap {
    pub id: i32,
    pub name: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}

#[derive(Clone, Debug, Queryable, Serialize)]
pub struct User {
    pub id: i32,
    pub name: String,
    pub email: String,
    pub password_hash: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
    pub username: String,
}

impl User {
    pub fn load_from_email_or_username(
        email_or_username: &str,
        connection: &PgConnection,
    ) -> Result<Option<Self>, DieselError> {
        use database_schema::users;

        let user: QueryResult<User> = users::table
            .filter(
                users::email
                    .eq(email_or_username)
                    .or(users::username.eq(email_or_username)),
            )
            .first(connection);

        match user {
            Ok(user) => Ok(Some(user)),
            Err(DieselError::NotFound) => Ok(None),
            Err(e) => Err(e),
        }
    }
}
