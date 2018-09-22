use chrono::NaiveDateTime;
use database;
use std::convert::From;

#[derive(GraphQLObject)]
#[graphql(description = "Someone following a roadmap")]
pub struct User {
    created_at: NaiveDateTime,
    id: i32,
    email: String,
    updated_at: NaiveDateTime,
    username: String,
    email_verified: bool,
}

impl From<database::User> for User {
    fn from(user: database::User) -> User {
        User {
            created_at: user.created_at,
            email: user.email,
            id: user.id,
            updated_at: user.updated_at,
            username: user.username,
            email_verified: user.email_verified,
        }
    }
}
