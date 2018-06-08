use failure::Error;

pub static DEFAULT_ENVIRONMENT_NAME: &'static str = "development";
static PRODUCTION: &'static str = "production";

#[derive(Fail, Debug)]
#[fail(display = "Unknown environment {}", name)]
struct UnknownEnvironment {
    name: String,
}

#[derive(Debug)]
pub enum Environment {
    Development,
    Production,
}

impl Environment {
    pub fn from_name(name: &str) -> Result<Self, Error> {
        if name == DEFAULT_ENVIRONMENT_NAME {
            Ok(Environment::Development)
        } else if name == PRODUCTION {
            Ok(Environment::Production)
        } else {
            Err(UnknownEnvironment {
                name: name.to_string(),
            })?
        }
    }

    pub fn secrets_keeper_root(&self) -> String {
        match self {
            Environment::Development => "http://localhost:5001".to_string(),
            Environment::Production => "https://secrets.ops.coconutestate.top".to_string(),
        }
    }
}
