use failure::Error;
use psst;

static APPLICATION_NAME: &'static str = "coconut-estate-toolbox";

pub fn get(key: &str) -> Result<String, Error> {
    Ok(psst::new(APPLICATION_NAME)?.get(key)?)
}
