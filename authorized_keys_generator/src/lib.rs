use failure::Error;
use failure_derive::Fail;

use log::debug;
use reqwest::Client;

#[derive(Fail, Debug)]
#[fail(display = "Could not fetch keys for {} because {}", username, status)]
struct UnexpectedStatusCode {
    status: reqwest::StatusCode,
    username: String,
}

#[derive(Debug)]
pub struct Key {
    pub username: String,
    pub public_key: String,
}

pub struct Generator {
    pub keys: Vec<Key>,
}

impl Generator {
    pub fn new(usernames: Vec<&str>) -> Result<Self, Error> {
        debug!("Considering usernames: {:#?}", usernames);
        let mut result = Self { keys: vec![] };

        let client = Client::new();

        for username in usernames {
            let mut response = client
                .get(&format!("https://github.com/{}.keys", username))
                .send()?;

            let status = response.status();
            if status != reqwest::StatusCode::OK {
                Err(UnexpectedStatusCode {
                    status: status,
                    username: username.to_string(),
                })?;
            }

            let text = response.text()?;

            for line in text.lines() {
                result.keys.push(Key {
                    username: username.to_string(),
                    public_key: line.to_string(),
                });
            }
        }

        Ok(result)
    }

    pub fn authorized_keys_format(&self) -> String {
        let mut result = String::new();
        result.push_str("# authorized keys generated from authorized_keys_generator");

        for key in &self.keys {
            result.push_str(&format!("\n\n# @{}\n{}", key.username, key.public_key));
        }

        result
    }
}
