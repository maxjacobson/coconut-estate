#[macro_use]
extern crate clap;
use clap::{App as ClapApp, AppSettings, Arg, SubCommand};

#[macro_use]
extern crate serde_derive;

extern crate actix_web;
use actix_web::{http::Method, middleware, server, App, HttpRequest, Json, Result};

extern crate env_logger;
#[macro_use]
extern crate log;

#[derive(Serialize)]
struct Roadmap {
    title: String,
}

#[derive(Serialize)]
struct RoadmapsResponse {
    roadmaps: Vec<Roadmap>,
}

fn list_roadmaps(_data: HttpRequest) -> Result<Json<RoadmapsResponse>> {
    let roadmaps = vec![Roadmap {
        title: "Learning Ruby".to_string(),
    }];
    Ok(Json(RoadmapsResponse { roadmaps }))
}

fn main() {
    let matches = ClapApp::new("api")
        .about("An HTTP API server")
        .setting(AppSettings::SubcommandRequiredElseHelp)
        .setting(AppSettings::VersionlessSubcommands)
        .version(crate_version!())
        .subcommand(
            SubCommand::with_name("run").about("Run the server").arg(
                Arg::with_name("binding")
                    .short("b")
                    .long("binding")
                    .value_name("BINDING")
                    .help("What to bind the service to (e.g. localhost:5001)")
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
        env_logger::init();

        info!("Starting...");

        server::new(move || {
            App::new()
                .middleware(middleware::Logger::default())
                .resource("/roadmaps", |r| {
                    r.method(Method::GET).with(list_roadmaps);
                })
        }).bind(&binding)
            .expect(&format!("Can not bind to {}", binding))
            .run();
    } else {
        panic!("whaaaaaaat");
    }
}
