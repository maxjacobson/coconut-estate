#[macro_use]
extern crate clap;
use clap::{App as ClapApp, AppSettings, Arg, SubCommand};
extern crate env_logger;
#[macro_use]
extern crate log;
#[macro_use]
extern crate serde_derive;
extern crate warp;

use std::fs::File;
use std::fs::{self, OpenOptions};
use std::io::prelude::*;
use std::path::Path;
use warp::http::StatusCode;
use warp::Filter;

#[derive(Debug, Clone)]
struct Location {
    path: String,
}

#[derive(Serialize, Deserialize, Debug)]
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
struct SecretsResponse {
    secrets: Vec<Secret>,
}

// TODO: add error handling instead of using unwrap
fn read_secrets(query: ReadSecretFilters, location: Location) -> impl warp::Reply {
    debug!("In read_secrets");
    debug!("Query is {:?}", query);
    debug!("Location is {:?}", location);

    let mut secrets = vec![];
    let dir = Path::new(&location.path).join(&query.group);
    match query.secret {
        Some(secret) => {
            let path = dir.join(&secret);

            let mut f = File::open(path).unwrap();
            let mut contents = String::new();
            f.read_to_string(&mut contents).unwrap();

            secrets.push(Secret {
                group: query.group.to_string(),
                name: secret.to_string(),
                value: contents.to_string(),
            });
        }
        None => {
            for entry_result in dir.read_dir().unwrap() {
                let entry = entry_result.unwrap();
                if entry.file_type().unwrap().is_file() {
                    let file_name = entry.file_name();

                    let mut f = File::open(entry.path()).unwrap();
                    let mut contents = String::new();
                    f.read_to_string(&mut contents).unwrap();

                    secrets.push(Secret {
                        group: query.group.to_string(),
                        name: file_name.into_string().expect("to be a string"),
                        value: contents.to_string(),
                    });
                }
            }
        }
    }

    let secret_response = SecretsResponse { secrets };

    warp::reply::json(&secret_response)
}

fn write_secret(secret: Secret, location: Location) -> impl warp::Reply {
    debug!("In write_secret");
    debug!("Writing {} secret in group {}", secret.name, secret.group);
    debug!("Location is {:?}", location);

    let dir = Path::new(&location.path).join(&secret.group);
    if !Path::exists(&dir) {
        fs::create_dir_all(&dir).unwrap();
    }
    let path = dir.join(&secret.name);
    if !Path::exists(&path) {
        File::create(&path).unwrap();
    }
    let mut file = OpenOptions::new().write(true).open(&path).unwrap();
    file.write_all(secret.value.as_bytes()).unwrap();

    StatusCode::CREATED
}

fn start_server(binding: &str, location: Location) -> Result<(), std::net::AddrParseError> {
    info!("Starting...");

    let location = warp::any().map(move || location.clone());

    // just represents the path...
    let secrets = warp::path("secrets");
    let secrets_index = secrets.and(warp::path::index());

    let read_secrets_route = warp::get(
        secrets
            .and(warp::query::<ReadSecretFilters>())
            .and(location.clone()),
    ).map(read_secrets);

    let write_secret_route =
        warp::post(secrets_index.and(warp::body::json()).and(location.clone())).map(write_secret);

    let routes = read_secrets_route
        .or(write_secret_route)
        .with(warp::log("secrets_keeper"));

    let binding: std::net::SocketAddr = binding.parse()?;

    warp::serve(routes).run(binding);

    Ok(())
}

fn main() {
    env_logger::init();

    let matches = ClapApp::new("Secrets keeper")
        .about("A web service for reading and writing secrets")
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
                        .help("What to bind the service to (e.g. localhost:5002)")
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
        let binding = matches
            .value_of("binding")
            .expect("binding to be provided (it's required)")
            .to_string();
        let location_path = matches
            .value_of("location")
            .expect("location to be provided (it's required)")
            .to_string();

        let location = Location {
            path: location_path,
        };

        start_server(&binding, location).unwrap();
    } else {
        panic!("whaaaaaaat");
    }
}
