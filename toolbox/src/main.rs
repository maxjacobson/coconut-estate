extern crate failure;
#[macro_use]
extern crate failure_derive;

use failure::Error;

mod cli;

fn main() -> Result<(), Error> {
    cli::App::new().run()
}
