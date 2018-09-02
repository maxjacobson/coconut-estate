#[derive(GraphQLObject)]
#[graphql(description = "Details of a successful sign in")]
pub struct SignIn {
    pub token: String,
}
