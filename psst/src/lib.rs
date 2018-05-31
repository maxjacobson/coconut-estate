extern crate failure;
#[macro_use]
extern crate failure_derive;
extern crate rprompt;
extern crate toml;
extern crate xdg;

#[macro_use]
extern crate log;

use std::fs::File;
use std::io::prelude::*;
use std::path::Path;

use std::fs::OpenOptions;

use failure::Error;

#[derive(Fail, Debug)]
#[fail(display = "Expected {} to be a string, but it wasn't", key)]
struct NotStringError {
    key: String,
}

pub struct PsstApplication {
    xdg_dirs: xdg::BaseDirectories,
}

impl PsstApplication {
    pub fn get(&self, key: &str) -> Result<String, Error> {
        let path = self.xdg_dirs.place_data_file("psst.toml")?;

        if !Path::exists(&path) {
            File::create(&path)?;
        }

        let current_content = {
            let mut file = File::open(&path)?;
            let mut content = String::new();
            file.read_to_string(&mut content)?;

            content
        };

        let mut table = current_content.parse::<toml::Value>()?;

        {
            if let Some(value) = table.get(key) {
                debug!("Using {} value from {:?}", key, path);
                if let Some(str_value) = value.as_str() {
                    return Ok(str_value.to_string());
                } else {
                    Err(NotStringError {
                        key: key.to_string(),
                    })?;
                }
            }
        }

        let new_value = self.get_new_value_for(key)?;
        let new_table = table.as_table_mut().unwrap();
        new_table.insert(key.to_string(), toml::Value::String(new_value.to_string()));

        let new_toml = toml::to_string(&new_table)?;

        debug!("Updating {:?} with new value", path);
        let mut file = OpenOptions::new().write(true).open(&path)?;
        file.write_all(new_toml.as_bytes())?;

        Ok(new_value)
    }

    fn get_new_value_for(&self, key: &str) -> Result<String, Error> {
        debug!("Prompting for new value for {}", key);
        let reply = rprompt::prompt_reply_stdout(&format!("Please provide a value for {}: ", key))?;

        Ok(reply)
    }
}

pub fn new(application: &str) -> Result<PsstApplication, Error> {
    let xdg_dirs = xdg::BaseDirectories::with_prefix(application)?;

    Ok(PsstApplication { xdg_dirs })
}
