use juniper::{self, FieldResult, RootNode};

use graphql;
use handlers::RequestContext;
use mutations;
use queries;

impl juniper::Context for RequestContext {}

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
        let id = context.claims.as_ref().unwrap().id; // TODO: don't unwrap
        Ok(queries::users::find(id, connection)?)
    }
});

pub struct MutationRoot;

graphql_object!(MutationRoot: RequestContext |&self| {
    field createUser(&executor, name: String, email: String, password: String, username: String) -> FieldResult<graphql::User> {
        let connection = &executor.context().pool.get()?;
        Ok(mutations::users::create(name, email, password, username, connection)?)
    }

    field createRoadmap(&executor, name: String) -> FieldResult<graphql::Roadmap> {
        let connection = &executor.context().pool.get()?;
        Ok(mutations::roadmaps::create(name, &connection)?)
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
