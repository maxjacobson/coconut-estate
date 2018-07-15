use actix_web::{http::Method, middleware, middleware::cors::Cors, server, App as ActixWebApp};

use handlers::list_roadmaps;

pub struct App;

impl App {
    pub fn run(cors_allowed_origin: String, binding: String) {
        server::new(move || {
            ActixWebApp::new()
                .middleware(middleware::Logger::default())
                .configure(|app| {
                    Cors::for_app(app)
                        .allowed_origin(&cors_allowed_origin)
                        .resource("/roadmaps", |r| {
                            r.method(Method::GET).with(list_roadmaps);
                        })
                        .register()
                })
        }).bind(&binding)
            .expect(&format!("Can not bind to {}", binding))
            .run();
    }
}
