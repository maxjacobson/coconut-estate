#[macro_use]
extern crate clap;
extern crate failure;
#[macro_use]
extern crate failure_derive;

use failure::Error;

mod cli;
mod environments;
mod secrets;

fn main() -> Result<(), Error> {
    cli::App::new().run()
}
