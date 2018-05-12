use clap::{App as ClapApp, AppSettings, Arg, SubCommand};
use failure::Error;

use secrets;

#[derive(Fail, Debug)]
#[fail(display = "No implementation for the provided, apparently valid, input available")]
struct UnimplementedValidInputError;

pub struct App;

impl App {
    pub fn new() -> Self {
        App
    }

    pub fn run(&self) -> Result<(), Error> {
        let matches = ClapApp::new("Toolbox")
            .about("CLI for operating production")
            .setting(AppSettings::SubcommandRequired)
            .version(crate_version!())
            .subcommand(
                SubCommand::with_name("secrets")
                    .about("Interact with the secrets keeper service")
                    .setting(AppSettings::SubcommandRequired)
                    .subcommand(
                        SubCommand::with_name("write")
                            .about("Write secrets to the secrets keeper service")
                            .arg(
                                Arg::with_name("environment")
                                    .short("e")
                                    .long("env")
                                    .value_name("ENVIRONMENT")
                                    .help("Specifies which environment to target")
                                    .required(false)
                                    .takes_value(true),
                            )
                            .arg(
                                Arg::with_name("VARIABLE")
                                    .help("The environment variable name for the new secret")
                                    .required(true)
                                    .index(1),
                            )
                            .arg(
                                Arg::with_name("VALUE")
                                    .help("The value of the new secret")
                                    .required(true)
                                    .index(2),
                            ),
                    ),
            )
            .get_matches();

        if let Some(matches) = matches.subcommand_matches("secrets") {
            secrets::App::lookup(matches)?.run()
        } else {
            Err(UnimplementedValidInputError)?
        }
    }
}
