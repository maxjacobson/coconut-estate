use chrono::NaiveDateTime;
use database;
use std::convert::From;

#[derive(GraphQLObject)]
#[graphql(description = "Someone following a roadmap")]
pub struct User {
    created_at: NaiveDateTime,
    id: i32,
    name: String,
    email: String,
    updated_at: NaiveDateTime,
    username: String,
}

impl From<database::User> for User {
    fn from(user: database::User) -> User {
        User {
            created_at: user.created_at,
            email: user.email,
            id: user.id,
            name: user.name,
            updated_at: user.updated_at,
            username: user.username,
        }
    }
}
