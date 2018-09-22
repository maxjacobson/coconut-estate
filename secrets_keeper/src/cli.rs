use clap::{App as ClapApp, AppSettings, Arg, SubCommand};
use location::Location;
use server::start as start_server;

pub struct App;

impl App {
    pub fn run() {
        let matches = ClapApp::new("Secrets keeper")
            .about("A web service for reading and writing secrets")
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
                            .help("What to bind the service to (e.g. localhost:5002)")
                            .required(true)
                            .takes_value(true),
                    ).arg(
                        Arg::with_name("location")
                            .short("l")
                            .long("location")
                            .value_name("LOCATION")
                            .help("Path to a directory where secrets ought to be kept")
                            .required(true)
                            .takes_value(true),
                    ),
            ).get_matches();

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
}
