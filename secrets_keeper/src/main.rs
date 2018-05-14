#[macro_use]
extern crate clap;
use clap::{App as ClapApp, AppSettings, Arg, SubCommand};

extern crate actix_web;
use actix_web::{middleware, server, App, HttpRequest};

extern crate env_logger;
#[macro_use]
extern crate log;

fn index(_req: HttpRequest) -> &'static str {
    "Hello world!"
}

fn main() {
    let matches = ClapApp::new("Secrets keeper")
        .about("A web service for reading and writing secrets")
        .setting(AppSettings::SubcommandRequired)
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
        let binding = matches.value_of("binding").unwrap().to_string();
        env_logger::init();

        info!("Starting...");

        server::new(|| {
            App::new()
                .resource("/", |r| r.f(index))
                .middleware(middleware::Logger::default())
        }).bind(&binding)
            .expect(&format!("Can not bind to {}", binding))
            .run();
    } else {
        panic!("whaaaaaaat");
    }
}
