use juniper::{self, FieldResult, RootNode};
use std::convert::From;

use graphql;
use handlers::RequestContext;
use mutations;
use queries;

impl juniper::Context for RequestContext {}

struct MissingClaims;

impl From<MissingClaims> for juniper::FieldError {
    fn from(_e: MissingClaims) -> juniper::FieldError {
        juniper::FieldError::new(
            "Can't access this resource without providing a token",
            juniper::Value::null(),
        )
    }
}

pub struct QueryRoot;

graphql_object!(QueryRoot: RequestContext |&self| {
    field roadmap(&executor, id: i32) -> FieldResult<graphql::Roadmap> {
        let connection = &executor.context().pool.get()?;
        Ok(queries::roadmaps::find(id, connection)?)
    }

    field roadmaps(&executor) -> FieldResult<Vec<graphql::Roadmap>> {
        let connection = &executor.context().pool.get()?;
        Ok(queries::roadmaps::all(connection)?)
    }

    field user(&executor) -> FieldResult<graphql::User> {
        // TODO: plop an optional User onto the context instead of the claim?
        let context = executor.context();
        let connection = &context.pool.get()?;
        let id = match context.claims.as_ref() {
            Some(claims) => claims.id,
            None => Err(MissingClaims)?,
        };

        // let id = context.claims.as_ref().unwrap().id; // TODO: don't unwrap
        Ok(queries::users::find(id, connection)?)
    }
});

pub struct MutationRoot;

graphql_object!(MutationRoot: RequestContext |&self| {
    field createUser(&executor, email: String, password: String, username: String) -> FieldResult<graphql::User> {
        let connection = &executor.context().pool.get()?;
        Ok(mutations::users::create(email, password, username, connection)?)
    }

    field updateUser(&executor, password: Option<String>) -> FieldResult<graphql::User> {
        let context = executor.context();
        let connection = &context.pool.get()?;
        let id = match context.claims.as_ref() {
            Some(claims) => claims.id,
            None => Err(MissingClaims)?,
        };

        Ok(mutations::users::update(id, password, connection)?)
    }

    field createRoadmap(&executor, name: String) -> FieldResult<graphql::Roadmap> {
        let context = executor.context();
        let connection = &context.pool.get()?;
        let id = match context.claims.as_ref() {
            Some(claims) => claims.id,
            None => Err(MissingClaims)?,
        };
        Ok(mutations::roadmaps::create(name, id, &connection)?)
    }

    field signIn(&executor, email_or_username: String, password: String) -> FieldResult<graphql::SignIn> {
        let context = executor.context();
        let connection = &context.pool.get()?;
        let jwt_secret = &context.jwt_secret;

        Ok(mutations::signin::create(email_or_username, password, &connection, &jwt_secret)?)
    }
});

pub type Schema = RootNode<'static, QueryRoot, MutationRoot>;

pub fn create_schema() -> Schema {
    Schema::new(QueryRoot {}, MutationRoot {})
}
