extern crate chrono;

#[macro_use]
extern crate clap;
use clap::{App as ClapApp, AppSettings, Arg, SubCommand};

#[macro_use]
extern crate serde_derive;

extern crate actix_web;
use actix_web::{
    http::Method, middleware, middleware::cors::Cors, server, App, HttpRequest, Json, Result,
};

extern crate env_logger;
#[macro_use]
extern crate log;

#[macro_use]
extern crate diesel;

mod models;
use models::*;
mod schema;

use diesel::pg::PgConnection;
use diesel::prelude::*;

use std::env;

#[derive(Serialize)]
struct RoadmapResponse {
    attributes: Roadmap,
    id: i32,
    #[serde(rename = "type")]
    kind: String,
}

impl RoadmapResponse {
    fn new(roadmap: Roadmap) -> Self {
        RoadmapResponse {
            id: roadmap.id,
            attributes: roadmap,
            kind: "roadmap".to_string(),
        }
    }
}

#[derive(Serialize)]
struct RoadmapsResponse {
    data: Vec<RoadmapResponse>,
}

fn list_roadmaps(_data: HttpRequest) -> Result<Json<RoadmapsResponse>> {
    // TODO: figure out a way to manage a connection pool rather than establishing a connection on
    // each request
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    let conn = PgConnection::establish(&database_url)
        .expect(&format!("Error connecting to {}", database_url));

    let roadmaps_list = {
        use schema::roadmaps::dsl::*;

        roadmaps.limit(5).load::<Roadmap>(&conn).unwrap()
    };

    Ok(Json(RoadmapsResponse {
        data: roadmaps_list
            .iter()
            .map(|roadmap| RoadmapResponse::new((*roadmap).clone()))
            .collect(),
    }))
}

fn main() {
    let matches = ClapApp::new("api")
        .about("An HTTP API server")
        .setting(AppSettings::SubcommandRequiredElseHelp)
        .setting(AppSettings::VersionlessSubcommands)
        .version(crate_version!())
        .subcommand(
            SubCommand::with_name("run")
                .about("Run the server")
                .arg(
                    Arg::with_name("binding")
                        .short("b")
                        .long("binding")
                        .value_name("BINDING")
                        .help("What to bind the service to (e.g. localhost:5001)")
                        .required(true)
                        .takes_value(true),
                )
                .arg(
                    Arg::with_name("cors_allowed_origin")
                        .short("c")
                        .long("cors")
                        .value_name("ORIGIN")
                        .help("Hosts to allow CORS requests from (e.g. http://localhost:5001)")
                        .required(true)
                        .takes_value(true),
                ),
        )
        .get_matches();

    if let Some(matches) = matches.subcommand_matches("run") {
        let binding = matches
            .value_of("binding")
            .expect("binding to be provided (it's required)")
            .to_string();

        let cors_allowed_origin = matches
            .value_of("cors_allowed_origin")
            .expect("cors_allowed_origin to be provided (it's required)")
            .to_string();

        env_logger::init();

        info!("Starting...");

        server::new(move || {
            App::new()
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
    } else {
        panic!("whaaaaaaat");
    }
}
