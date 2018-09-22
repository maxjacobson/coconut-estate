use actix_web::{http::Method, middleware, middleware::cors::Cors, server, App as ActixWebApp};
use diesel::prelude::PgConnection;
use diesel::r2d2::ConnectionManager;
use r2d2;

use handlers::respond_to_graphql_request;

use graphql_schema::{create_schema, Schema};

use std::env;

pub struct App;

pub struct ServerState {
    pub schema: Schema,
    pub pool: r2d2::Pool<ConnectionManager<PgConnection>>,
    pub jwt_secret: String,
}

impl App {
    pub fn run(cors_allowed_origin: String, binding: String) {
        server::new(move || {
            let schema = create_schema();

            let pg_user = Self::read_env("POSTGRES_USER");
            let pg_password = Self::read_env("POSTGRES_PASSWORD");
            let pg_host = Self::read_env("POSTGRES_HOST");
            let pg_port = Self::read_env("POSTGRES_PORT");
            let pg_database = Self::read_env("PG_DATABASE");
            let jwt_secret = Self::read_env("JWT_SECRET");

            let database_url = format!(
                "postgres://{}:{}@{}:{}/{}",
                pg_user, pg_password, pg_host, pg_port, pg_database
            );

            let manager: ConnectionManager<PgConnection> = ConnectionManager::new(database_url);
            let pool = r2d2::Pool::builder().max_size(15).build(manager).unwrap();

            ActixWebApp::with_state(ServerState {
                schema,
                pool,
                jwt_secret,
            }).middleware(middleware::Logger::default())
            .configure(|app| {
                Cors::for_app(app)
                    .allowed_origin(&cors_allowed_origin)
                    .resource("/graphql", |r| {
                        r.method(Method::POST).with(respond_to_graphql_request)
                    }).register()
            })
        }).bind(&binding)
        .expect(&format!("Can not bind to {}", binding))
        .run();
    }

    fn read_env(var: &str) -> String {
        env::var(var).unwrap_or_else(|_e| panic!("{} not set in env", var))
    }
}
