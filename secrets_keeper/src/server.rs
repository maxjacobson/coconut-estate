use location::Location;
use std::fs::File;
use std::fs::{self, OpenOptions};
use std::io::prelude::*;
use std::{self, path::Path};
use warp::{self, http::StatusCode, Filter};

pub fn start(binding: &str, location: Location) -> Result<(), std::net::AddrParseError> {
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
