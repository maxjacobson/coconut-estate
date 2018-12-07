use clap;
use clap_helpers::read_arg;
use environments::{self, Environment};
use failure::Error;
use reqwest;
use std::collections::HashMap;

#[derive(Fail, Debug)]
#[fail(
    display = "No implementation for the provided, apparently valid, secrets subcommand available. This suggests the CLI says it supports this, you just haven't implemented it yet."
)]
struct UnimplementedSecretsSubcommand;

#[derive(Fail, Debug)]
#[fail(display = "Expected {}, received {}", expected, status)]
struct UnexpectedResponseFromSecretsKeeper {
    expected: reqwest::StatusCode,
    status: reqwest::StatusCode,
}

pub enum SecretsApp {
    Read {
        environment: Environment,
        group: String,
        secret_name: Option<String>,
    },
    Write {
        environment: Environment,
        group: String,
        secret_name: String,
        secret: String,
    },
}

impl SecretsApp {
    pub fn run(&self) -> Result<(), Error> {
        match self {
            &SecretsApp::Read {
                ref environment,
                ref group,
                ref secret_name,
            } => Ok(self.read_secret(environment, group, secret_name)?),
            &SecretsApp::Write {
                ref environment,
                ref group,
                ref secret_name,
                ref secret,
            } => Ok(self.write_secret(environment, group, secret_name, secret)?),
        }
    }

    fn read_secret(
        &self,
        environment: &Environment,
        group: &str,
        secret_name: &Option<String>,
    ) -> Result<(), Error> {
        let client = reqwest::Client::new();

        let mut response = match secret_name {
            Some(secret_name) => client
                .get(&self.secrets_path(environment))
                .query(&[("group", group), ("secret", secret_name)])
                .send()?,
            None => client
                .get(&self.secrets_path(environment))
                .query(&[("group", group)])
                .send()?,
        };

        self.validate_response(&mut response, reqwest::StatusCode::OK, true)
    }

    fn write_secret(
        &self,
        environment: &Environment,
        group: &str,
        secret_name: &str,
        secret: &str,
    ) -> Result<(), Error> {
        let client = reqwest::Client::new();
        let mut body = HashMap::new();
        body.insert("group", group);
        body.insert("name", secret_name);
        body.insert("value", secret);
        let mut response = client
            .post(&self.secrets_path(environment))
            .json(&body)
            .send()?;

        self.validate_response(&mut response, reqwest::StatusCode::CREATED, false)
    }

    // N.B.: this might become more complicated later on when tunneling
    // requests through the bastion, but ... hopefully not?
    fn secrets_path(&self, environment: &Environment) -> String {
        format!("{}/secrets", environment.secrets_keeper_root())
    }

    fn validate_response(
        &self,
        response: &mut reqwest::Response,
        expected: reqwest::StatusCode,
        print_body: bool,
    ) -> Result<(), Error> {
        let status = response.status();

        if status == expected {
            match response.text() {
                Ok(text) => {
                    if print_body {
                        println!("{}", text);
                    } else {
                        println!("Success!");
                    }

                    Ok(())
                }
                e @ _ => {
                    println!("Welp, couldn't read response body because {:?}", e);
                    Ok(())
                }
            }
        } else {
            Err(UnexpectedResponseFromSecretsKeeper { expected, status })?
        }
    }
}

pub struct App;

impl App {
    pub fn lookup(matches: &clap::ArgMatches) -> Result<SecretsApp, Error> {
        if let Some(matches) = matches.subcommand_matches("read") {
            let environment_name = matches
                .value_of("environment")
                .unwrap_or(environments::DEFAULT_ENVIRONMENT_NAME);
            let environment = Environment::from_name(environment_name)?;
            let group = read_arg(matches, "group")?;
            let secret_name: Option<String> = matches.value_of("variable").map(|s| s.to_string());

            Ok(SecretsApp::Read {
                environment,
                group,
                secret_name,
            })
        } else if let Some(matches) = matches.subcommand_matches("write") {
            let environment_name = matches
                .value_of("environment")
                .unwrap_or(environments::DEFAULT_ENVIRONMENT_NAME);

            let environment = Environment::from_name(environment_name)?;

            let group = read_arg(matches, "group")?;
            let secret_name = read_arg(matches, "variable")?;
            let secret = read_arg(matches, "value")?;

            Ok(SecretsApp::Write {
                environment,
                group,
                secret_name,
                secret,
            })
        } else {
            Err(UnimplementedSecretsSubcommand)?
        }
    }
}
