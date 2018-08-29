use chrono::NaiveDateTime;
use diesel::prelude::{ExpressionMethods, QueryDsl, RunQueryDsl};
use juniper::{self, FieldError, FieldResult, RootNode};

use app::AppState;
use database_schema::{roadmaps, users};
use diesel::dsl::insert_into;
use libpasta;
use models;

impl juniper::Context for AppState {}

#[derive(GraphQLObject)]
#[graphql(description = "A plan to follow")]
struct Roadmap {
    created_at: NaiveDateTime,
    id: i32,
    name: String,
    updated_at: NaiveDateTime,
}

#[derive(GraphQLObject)]
#[graphql(description = "Someone following a roadmap")]
struct User {
    created_at: NaiveDateTime,
    id: i32,
    name: String,
    email: String,
    updated_at: NaiveDateTime,
    username: String,
}

#[derive(GraphQLObject)]
#[graphql(description = "Details of a successful sign in")]
struct SignIn {
    token: String,
}

pub struct QueryRoot;

graphql_object!(QueryRoot: AppState |&self| {
    field roadmap(&executor, id: i32) -> FieldResult<Roadmap> {
        let context = executor.context();

        debug!("Looking up roadmap with id {}", id);

        let roadmap: models::Roadmap = roadmaps::table.filter(roadmaps::id.eq(id)).first(&context.connection)?;

        Ok(Roadmap{
            created_at: roadmap.created_at,
            id: roadmap.id,
            name: roadmap.name,
            updated_at: roadmap.updated_at,
        })
    }

    field roadmaps(&executor) -> FieldResult<Vec<Roadmap>> {
        // TODO: consider moving as much code as possible out of macros so rustfmt can be more sure
        // how to reformat it
        let context = executor.context();

        let roadmaps: Vec<models::Roadmap> = roadmaps::table.load(&context.connection)?;

        Ok(roadmaps.iter().map(|roadmap| Roadmap {
            created_at: roadmap.created_at,
            id: roadmap.id,
            name: roadmap.name.clone(),
            updated_at: roadmap.updated_at,
        }).collect())
    }
});

pub struct MutationRoot;

graphql_object!(MutationRoot: AppState |&self| {
    field createUser(&executor, name: String, email: String, password: String, username: String) -> FieldResult<User> {
        debug!("Attempting to insert a user with name: {}, email: {}", name, email);
        let context = executor.context();

        let password_hash = libpasta::hash_password(&password);

        let user: models::User = insert_into(users::table).values(
            (
                users::name.eq(name),
                users::email.eq(email),
                users::password_hash.eq(password_hash),
                users::username.eq(username),
            )
        ).get_result(&context.connection)?;

        Ok(User {
            created_at: user.created_at,
            email: user.email,
            id: user.id,
            name: user.name,
            updated_at: user.updated_at,
            username: user.username,
        })
    }

    field createRoadmap(&executor, name: String) -> FieldResult<Roadmap> {
        debug!("Attempting to insert a roadmap with name: {}", name);

        let context = executor.context();

        let roadmap: models::Roadmap = insert_into(roadmaps::table).
            values(roadmaps::name.eq(&name)).get_result(&context.connection)?;

        Ok(Roadmap{
            created_at: roadmap.created_at,
            id: roadmap.id,
            name: roadmap.name,
            updated_at: roadmap.updated_at,
        })
    }

    field signIn(&executor, email_or_username: String, password: String) -> FieldResult<SignIn> {
        debug!("Attempting to sign in as {}", email_or_username);

        let context = executor.context();

        if let Some(user) = models::User::load_from_email_or_username(&email_or_username, &context.connection)? {
            if libpasta::verify_password(&user.password_hash, &password) {
                let token = "????".to_string(); // TODO: real token?

                Ok(SignIn { token })
            } else {
                Err(
                    FieldError::new(
                        "Password did not match",
                        graphql_value!({ "sign_in": "Password did not match" }),
                    )
                )
            }
        } else {
            Err(
                FieldError::new(
                    "No user found",
                    graphql_value!({ "sign_in": "No user found" }),
                )
            )
        }
    }
});

pub type Schema = RootNode<'static, QueryRoot, MutationRoot>;

pub fn create_schema() -> Schema {
    Schema::new(QueryRoot {}, MutationRoot {})
}
