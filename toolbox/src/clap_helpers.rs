use clap;
use failure::Error;

#[derive(Fail, Debug)]
#[fail(
    display = "Expected arg value for {}, but wasn't available. This suggests you tried to read something that the CLI can't actually contain.",
    name
)]
struct MissingArgError {
    name: String,
}

pub fn read_arg(matches: &clap::ArgMatches, arg: &str) -> Result<String, Error> {
    Ok(matches
        .value_of(arg)
        .ok_or_else(|| MissingArgError {
            name: arg.to_string(),
        })?.to_string())
}
