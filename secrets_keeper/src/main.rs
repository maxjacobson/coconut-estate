#[macro_use]
extern crate clap;
use clap::{App as ClapApp, AppSettings, Arg, SubCommand};

#[macro_use]
extern crate serde_derive;

extern crate actix_web;
use actix_web::{http::Method, middleware, server, App, HttpRequest, HttpResponse, Json, Query,
                Result};

extern crate env_logger;
#[macro_use]
extern crate log;

use std::fs::File;
use std::io::prelude::*;
use std::path::Path;

use std::fs::{self, OpenOptions};

#[derive(Debug)]
struct AppState {
    location: String,
}

#[derive(Debug, Deserialize, Serialize)]
struct Secret {
    group: String,
    name: String,
    value: String,
}

#[derive(Debug, Deserialize)]
struct ReadSecretFilters {
    group: String,
    secret: Option<String>,
}

#[derive(Serialize)]
struct ReadResponse {
    secrets: Vec<Secret>,
}

fn create_secret(data: (HttpRequest<AppState>, Json<Secret>)) -> HttpResponse {
    let (req, secret) = data;
    let state: &AppState = req.state();

    let dir = Path::new(&state.location).join(&secret.group);
    if !Path::exists(&dir) {
        fs::create_dir_all(&dir).unwrap(); // TODO: add failure
    }
    let path = dir.join(&secret.name);
    if !Path::exists(&path) {
        File::create(&path).unwrap(); // TODO: add failure
    }
    let mut file = OpenOptions::new().write(true).open(&path).unwrap(); // TODO: add failure
    file.write_all(secret.value.as_bytes()).unwrap(); // TODO: add failure

    HttpResponse::Ok().into()
}

fn read_secret(
    data: (HttpRequest<AppState>, Query<ReadSecretFilters>),
) -> Result<Json<ReadResponse>> {
    let (req, raw_filters) = data;
    let state: &AppState = req.state();
    let filters = raw_filters.into_inner();

    let mut secrets = vec![];

    let dir = Path::new(&state.location).join(&filters.group);
    match filters.secret {
        Some(secret) => {
            let path = dir.join(&secret);

            let mut f = File::open(path)?; // TODO: add failure
            let mut contents = String::new();
            f.read_to_string(&mut contents)?; //TODO: add failure

            secrets.push(Secret {
                group: filters.group.to_string(),
                name: secret.to_string(),
                value: contents.to_string(),
            });
        }
        None => {
            for entry_result in dir.read_dir()? {
                let entry = entry_result?;
                if entry.file_type()?.is_file() {
                    let file_name = entry.file_name();

                    let mut f = File::open(entry.path())?; // TODO: add failure
                    let mut contents = String::new();
                    f.read_to_string(&mut contents)?; //TODO: add failure

                    secrets.push(Secret {
                        group: filters.group.to_string(),
                        name: file_name.into_string().expect("to be a string"),
                        value: contents.to_string(),
                    });
                }
            }
        }
    }
    Ok(Json(ReadResponse { secrets: secrets }))
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
                .resource("/secrets", |r| {
                    r.method(Method::POST).with(create_secret);
                    r.method(Method::GET).with(read_secret);
                })
        }).bind(&binding)
            .expect(&format!("Can not bind to {}", binding))
            .run();
    } else {
        panic!("whaaaaaaat");
    }
}
