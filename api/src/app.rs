use actix_web::{http::Method, middleware, middleware::cors::Cors, server, App as ActixWebApp};

use handlers::respond_to_graphql_request;

use graphql_schema::{create_schema, Schema};

pub struct App;

pub struct AppState {
    pub schema: Schema,
}

impl App {
    pub fn run(cors_allowed_origin: String, binding: String) {
        server::new(move || {
            let schema = create_schema();

            ActixWebApp::with_state(AppState { schema })
                .middleware(middleware::Logger::default())
                .configure(|app| {
                    Cors::for_app(app)
                        .allowed_origin(&cors_allowed_origin)
                        .resource("/graphql", |r| {
                            r.method(Method::POST).with(respond_to_graphql_request)
                        })
                        .register()
                })
        }).bind(&binding)
            .expect(&format!("Can not bind to {}", binding))
            .run();
    }
}
