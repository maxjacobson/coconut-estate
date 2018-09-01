use actix_web::{HttpMessage, HttpRequest, HttpResponse, Json};
use app::ServerState;
use auth::Claims;
use diesel::r2d2::ConnectionManager;
use diesel::PgConnection;
use jsonwebtoken;
use juniper::http::GraphQLRequest;
use r2d2;
use serde_json;

pub struct RequestContext {
    pub pool: r2d2::Pool<ConnectionManager<PgConnection>>,
    pub jwt_secret: String,
    pub claims: Option<Claims>,
}

#[derive(Serialize, Deserialize)]
pub struct GraphQLData(GraphQLRequest);

pub fn respond_to_graphql_request(
    (data, req): (Json<GraphQLData>, HttpRequest<ServerState>),
) -> HttpResponse {
    let state: &ServerState = req.state();
    let authorization = req.headers().get("authorization");

    let claims = authorization.and_then(|bearer| {
        bearer
            .to_str()
            .expect("Valid ascii header value")
            .split_whitespace()
            .nth(1)
            .and_then(|token| {
                let token_data = jsonwebtoken::decode::<Claims>(
                    token,
                    &state.jwt_secret.as_ref(),
                    &jsonwebtoken::Validation::new(jsonwebtoken::Algorithm::HS256),
                ).expect("Decodable bearer token"); // TODO: non-decodable tokens should not panic

                Some(token_data.claims)
            })
    });

    let request_context = RequestContext {
        pool: state.pool.clone(),
        jwt_secret: state.jwt_secret.clone(),
        claims: claims,
    };

    let res = (data.0).0.execute(&state.schema, &request_context);

    let res_text = serde_json::to_string(&res).unwrap(); // TODO: this should return a result

    res_text.into()
}
