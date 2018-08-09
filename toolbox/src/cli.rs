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
            .setting(AppSettings::DisableVersion)
            .setting(AppSettings::SubcommandRequiredElseHelp)
            .setting(AppSettings::VersionlessSubcommands)
            .subcommand(
                SubCommand::with_name("secrets")
                    .about("Interact with the secrets keeper service")
                    .setting(AppSettings::SubcommandRequired)
                    .subcommand(
                        SubCommand::with_name("read")
                            .about("Reads secrest from the secrets keeper service")
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
                                Arg::with_name("group")
                                    .short("g")
                                    .long("group")
                                    .value_name("GROUP")
                                    .help("Which group of secrets to read from")
                                    .required(true)
                                    .takes_value(true),
                            )
                            .arg(
                                Arg::with_name("variable")
                                    .help("The environment variable you'd like to read")
                                    .value_name("VARIABLE")
                                    .required(false)
                                    .index(1),
                            ),
                    )
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
                                Arg::with_name("group")
                                    .short("g")
                                    .long("group")
                                    .value_name("GROUP")
                                    .help("Which group of secrets does this secret belong to?")
                                    .required(true)
                                    .takes_value(true),
                            )
                            .arg(
                                Arg::with_name("variable")
                                    .help("The environment variable name for the new secret")
                                    .value_name("VARIABLE")
                                    .required(true)
                                    .index(1),
                            )
                            .arg(
                                Arg::with_name("value")
                                    .help("The value of the new secret")
                                    .value_name("VALUE")
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
