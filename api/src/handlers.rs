use actix_web::{HttpResponse, Json};
use juniper::http::GraphQLRequest;
use serde_json;

use graphql_schema::create_schema;

#[derive(Serialize, Deserialize)]
pub struct GraphQLData(GraphQLRequest);

pub fn respond_to_graphql_request(data: Json<GraphQLData>) -> HttpResponse {
    // TODO: create the schema outside of the handler so the handler can just _use_ the schema
    // Just punted to get up and running, but it's totally doable (see
    // https://github.com/actix/examples/blob/master/juniper/src/main.rs)

    // TODO 2: this shouldd return a result

    let schema = create_schema();
    let res = (data.0).0.execute(&schema, &());

    let res_text = serde_json::to_string(&res).unwrap();

    res_text.into()
}
