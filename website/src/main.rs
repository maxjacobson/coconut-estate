#[macro_use]
extern crate clap;
use clap::{App as ClapApp, AppSettings, Arg, SubCommand};

extern crate actix_web;
use actix_web::http::{Method, StatusCode};
use actix_web::{fs, middleware, server, App, HttpRequest, HttpResponse};

extern crate env_logger;
#[macro_use]
extern crate log;

extern crate openssl;
use openssl::ssl::{SslAcceptor, SslFiletype, SslMethod};

use std::fs::File;
use std::io::prelude::*;

#[macro_use]
extern crate lazy_static;

lazy_static! {
    static ref INDEX: String = {
        let mut file = File::open("./website/index.html").unwrap();
        let mut contents = String::new();
        file.read_to_string(&mut contents).unwrap();

        contents
    };
}

fn default_handler(_req: HttpRequest) -> HttpResponse {
    HttpResponse::build(StatusCode::OK)
        .content_type("text/html; charset=utf-8")
        .body(INDEX.as_bytes())
}

fn main() {
    let matches = ClapApp::new("Website")
        .about("A user-facing website")
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
                    Arg::with_name("ssl")
                        .long("ssl")
                        .help("Pass this flag to opt in to serving the website over SSL")
                        .required(false)
                        .takes_value(false)
                        .requires_all(&["private key file", "certificate chain file"]),
                )
                .arg(
                    Arg::with_name("private key file")
                        .short("k")
                        .long("key")
                        .value_name("PATH TO PRIVATE KEY FILE")
                        .help("The path to the private key file")
                        .required(false)
                        .takes_value(true)
                        .requires_all(&["ssl", "certificate chain file"]),
                )
                .arg(
                    Arg::with_name("certificate chain file")
                        .short("c")
                        .long("cert")
                        .value_name("PATH TO CERTIFICATE CHAIN FILE")
                        .help("The path to the certificate chain file")
                        .required(false)
                        .takes_value(true)
                        .requires_all(&["private key file", "ssl"]),
                ),
        )
        .get_matches();

    if let Some(matches) = matches.subcommand_matches("run") {
        let binding = matches
            .value_of("binding")
            .expect("binding to be provided (it's required)")
            .to_string();
        let use_ssl = matches.is_present("ssl");

        env_logger::init();

        info!("Starting...");

        let unbound_server = server::new(move || {
            App::new()
                .middleware(middleware::Logger::default())
                .default_resource(|r| {
                    r.method(Method::GET).with(default_handler);
                })
                .handler("/assets/", fs::StaticFiles::new("./website/assets"))
        });

        if use_ssl {
            let path_to_private_key_file = matches
                .value_of("private key file")
                .expect("private key file to be present (It's required when ssl is passed")
                .to_string();

            let path_to_certificate_chain_file = matches
                .value_of("certificate chain file")
                .expect("certificate chain file to be present (It's required when ssl is passed")
                .to_string();

            let mut builder = SslAcceptor::mozilla_intermediate(SslMethod::tls()).unwrap();
            builder
                .set_private_key_file(&path_to_private_key_file, SslFiletype::PEM)
                .unwrap();
            builder
                .set_certificate_chain_file(&path_to_certificate_chain_file)
                .unwrap();

            unbound_server
                .bind_ssl(&binding, builder)
                .expect(&format!("Can not bind to {}", binding))
                .run();
        } else {
            unbound_server
                .bind(&binding)
                .expect(&format!("Can not bind to {}", binding))
                .run();
        }
    } else {
        panic!("whaaaaaaat");
    }
}
