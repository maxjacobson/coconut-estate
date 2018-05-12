use failure::Error;

pub static DEFAULT_ENVIRONMENT_NAME: &'static str = "development";

#[derive(Fail, Debug)]
#[fail(display = "Unknown environment {}", name)]
struct UnknownEnvironment {
    name: String,
}

#[derive(Debug)]
pub enum Environment {
    Development,
}

impl Environment {
    pub fn from_name(name: &str) -> Result<Self, Error> {
        match name {
            "development" => Ok(Environment::Development),
            _ => Err(UnknownEnvironment {
                name: name.to_string(),
            })?,
        }
    }
}
