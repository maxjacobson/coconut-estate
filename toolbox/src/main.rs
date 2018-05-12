extern crate failure;
#[macro_use]
extern crate failure_derive;

use failure::Error;

mod cli;

#[derive(Fail, Debug)]
#[fail(display = "An error occurred.")]
struct MyError;

fn main() -> Result<(), Error> {
    cli::App::new().run()
}
