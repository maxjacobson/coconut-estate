extern crate chrono;
#[macro_use]
extern crate clap;
#[macro_use]
extern crate serde_derive;
extern crate actix_web;
extern crate env_logger;
#[macro_use]
extern crate log;
#[macro_use]
extern crate diesel;

mod app;
mod cli;
mod database_schema;
mod handlers;
mod models;
mod responses;

use cli::Api;

fn main() {
    Api::start();
}
