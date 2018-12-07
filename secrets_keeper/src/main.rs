mod cli;
mod location;
mod server;

use crate::cli::App;

fn main() {
    env_logger::init();

    App::run();
}
