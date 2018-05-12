use clap;
use environments::{self, Environment};
use failure::Error;

#[derive(Fail, Debug)]
#[fail(display = "No implementation for the provided, apparently valid, secrets subcommand available. This suggests the CLI says it supports this, you just haven't implemented it yet.")]
struct UnimplementedSecretsSubcommand;

#[derive(Fail, Debug)]
#[fail(display = "Expected arg value for {}, but wasn't available. This suggests you tried to read something that the CLI can't actually contain.",
       name)]
struct MissingArgError {
    name: String,
}

pub enum SecretsApp {
    Write {
        environment: Environment,
        secret_name: String,
        secret: String,
    },
}

impl SecretsApp {
    pub fn run(&self) -> Result<(), Error> {
        match self {
            &SecretsApp::Write {
                ref environment,
                ref secret_name,
                ref secret,
            } => Ok(self.write_secret(environment, secret_name, secret)?),
        }
    }

    fn write_secret(
        &self,
        environment: &Environment,
        secret_name: &str,
        secret: &str,
    ) -> Result<(), Error> {
        // TODO: implement this
        println!(
            "[{:?}] Going to write {}={}",
            environment, secret_name, secret
        );
        Ok(())
    }
}

pub struct App;

impl App {
    pub fn lookup(matches: &clap::ArgMatches) -> Result<SecretsApp, Error> {
        if let Some(matches) = matches.subcommand_matches("write") {
            let environment_name = matches
                .value_of("environment")
                .unwrap_or(environments::DEFAULT_ENVIRONMENT_NAME);

            let environment = Environment::from_name(environment_name)?;

            let secret_name = Self::read_arg(matches, "VARIABLE")?;
            let secret = Self::read_arg(matches, "VALUE")?;

            Ok(SecretsApp::Write {
                environment,
                secret_name,
                secret,
            })
        } else {
            Err(UnimplementedSecretsSubcommand)?
        }
    }

    fn read_arg(matches: &clap::ArgMatches, arg: &str) -> Result<String, Error> {
        Ok(matches
            .value_of(arg)
            .ok_or_else(|| MissingArgError {
                name: arg.to_string(),
            })?
            .to_string())
    }
}
