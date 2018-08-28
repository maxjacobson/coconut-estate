use actix_web::{HttpResponse, Json, State};
use app::ServerState;
use juniper::http::GraphQLRequest;
use serde_json;

#[derive(Serialize, Deserialize)]
pub struct GraphQLData(GraphQLRequest);

pub fn respond_to_graphql_request(
    (state, data): (State<ServerState>, Json<GraphQLData>),
) -> HttpResponse {
    // TODO: this should return a result

    let res = (data.0).0.execute(&state.schema, &state.app_state);

    let res_text = serde_json::to_string(&res).unwrap();

    res_text.into()
}
