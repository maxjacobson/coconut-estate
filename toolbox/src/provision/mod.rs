mod secrets_keeper;

use clap;
use clap_helpers::read_arg;
use droplet_kinds::DropletKind;
use failure::Error;

#[derive(Debug)]
pub struct App {
    kind: DropletKind,
}

impl App {
    pub fn new(matches: &clap::ArgMatches) -> Result<Self, Error> {
        let kind = DropletKind::from_name(&read_arg(matches, "kind")?)?;

        Ok(Self { kind })
    }

    pub fn run(&self) -> Result<(), Error> {
        match self.kind {
            DropletKind::SecretsKeeper => secrets_keeper::Create::run()?,
        }

        Ok(())
    }
}
