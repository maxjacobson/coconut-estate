use clap;
use clap_helpers::read_arg;
use environments::{self, Environment};
use failure::Error;
use reqwest;
use std::collections::HashMap;

#[derive(Fail, Debug)]
#[fail(display = "No implementation for the provided, apparently valid, secrets subcommand available. This suggests the CLI says it supports this, you just haven't implemented it yet.")]
struct UnimplementedSecretsSubcommand;

#[derive(Fail, Debug)]
#[fail(display = "Expected 200 OK, received {}", status)]
struct UnexpectedResponseFromSecretsKeeper {
    status: reqwest::StatusCode,
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
        let client = reqwest::Client::new();
        let mut body = HashMap::new();
        body.insert("name", secret_name);
        body.insert("value", secret);
        let response = client
            .post(&self.write_secret_path_for(environment))
            .json(&body)
            .send()?;

        match response.status() {
            reqwest::StatusCode::Ok => {
                println!("Success!");
                Ok(())
            }
            status @ _ => Err(UnexpectedResponseFromSecretsKeeper { status })?,
        }
    }

    // N.B.: this might become more complicated later on when tunneling
    // requests through the bastion, but ... hopefully not?
    fn write_secret_path_for(&self, environment: &Environment) -> String {
        (environment.secrets_keeper_root() + "/secrets").to_string()
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

            let secret_name = read_arg(matches, "variable")?;
            let secret = read_arg(matches, "value")?;

            Ok(SecretsApp::Write {
                environment,
                secret_name,
                secret,
            })
        } else {
            Err(UnimplementedSecretsSubcommand)?
        }
    }
}
