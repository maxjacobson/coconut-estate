#[macro_use]
extern crate failure_derive;

mod clap_helpers;
mod cli;
mod environments;
mod secrets;

use log::error;
use std::process;

fn main() {
    env_logger::init();
    match cli::App::new().run() {
        Err(err) => {
            error!("{}", err);
            process::exit(1);
        }
        _ => {}
    }
}
