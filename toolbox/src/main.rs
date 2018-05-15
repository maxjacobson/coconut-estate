#[macro_use]
extern crate clap;
extern crate failure;
#[macro_use]
extern crate failure_derive;

use failure::Error;

mod clap_helpers;
mod cli;
mod droplet_kinds;
mod environments;
mod provision;
mod secrets;

fn main() -> Result<(), Error> {
    cli::App::new().run()
}
