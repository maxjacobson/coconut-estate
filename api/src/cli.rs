use clap::{App as ClapApp, AppSettings, Arg, SubCommand};
use env_logger;
use log::info;

use crate::app::App;

pub struct Api;

impl Api {
    pub fn start() {
        let matches = ClapApp::new("api")
            .about("An HTTP API server")
            .setting(AppSettings::DisableVersion)
            .setting(AppSettings::SubcommandRequiredElseHelp)
            .setting(AppSettings::VersionlessSubcommands)
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
                            .help("Host to allow CORS requests from (e.g. http://localhost:5000, if that's your front-end website)")
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

            App::run(cors_allowed_origin, binding);
        } else {
            panic!("whaaaaaaat");
        }
    }
}
