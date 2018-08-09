extern crate clap;
extern crate env_logger;
#[macro_use]
extern crate log;
#[macro_use]
extern crate serde_derive;
extern crate warp;

mod cli;
mod location;
mod server;

use cli::App;

fn main() {
    env_logger::init();

    App::run();
}
