#[macro_use]
extern crate clap;

extern crate failure;
#[macro_use]
extern crate failure_derive;

extern crate env_logger;
#[macro_use]
extern crate log;

extern crate psst;

extern crate reqwest;

#[macro_use]
extern crate serde_derive;

extern crate authorized_keys_generator;

mod authorized_keys;
mod clap_helpers;
mod cli;
mod digital_ocean;
mod droplet_kinds;
mod environments;
mod provision;
mod psst_helper;
mod secrets;

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
