#[macro_use]
extern crate clap;
use clap::{App as ClapApp, AppSettings, Arg, SubCommand};

#[macro_use]
extern crate serde_derive;

extern crate actix_web;
use actix_web::{middleware, server, App, HttpRequest, HttpResponse, Json, http::Method};

extern crate env_logger;
#[macro_use]
extern crate log;

use std::fs::File;
use std::io::prelude::*;
use std::path::Path;

use std::fs::OpenOptions;

#[derive(Debug)]
struct AppState {
    location: String,
}

#[derive(Debug, Deserialize)]
struct Secret {
    name: String,
    value: String,
}

fn create_secret(data: (HttpRequest<AppState>, Json<Secret>)) -> HttpResponse {
    let (req, secret) = data;
    let state: &AppState = req.state();

    let path = Path::new(&state.location).join(&secret.name);
    if !Path::exists(&path) {
        File::create(&path).unwrap(); // TODO: add failure
    }
    let mut file = OpenOptions::new().write(true).open(&path).unwrap(); // TODO: add failure
    file.write_all(secret.value.as_bytes()).unwrap(); // TODO: add failure

    HttpResponse::Ok().into()
}

fn main() {
    let matches = ClapApp::new("Secrets keeper")
        .about("A web service for reading and writing secrets")
        .setting(AppSettings::SubcommandRequired)
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
                    Arg::with_name("location")
                        .short("l")
                        .long("location")
                        .value_name("LOCATION")
                        .help("Path to a directory where secrets ought to be kept")
                        .required(true)
                        .takes_value(true),
                ),
        )
        .get_matches();

    if let Some(matches) = matches.subcommand_matches("run") {
        let binding = matches.value_of("binding").unwrap().to_string();
        let location = matches.value_of("location").unwrap().to_string();

        env_logger::init();

        info!("Starting...");

        server::new(move || {
            App::with_state(AppState {
                location: location.clone(),
            }).middleware(middleware::Logger::default())
                .resource("/secrets", |r| r.method(Method::POST).with(create_secret))
        }).bind(&binding)
            .expect(&format!("Can not bind to {}", binding))
            .run();
    } else {
        panic!("whaaaaaaat");
    }
}
