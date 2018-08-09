extern crate actix_web;

extern crate chrono;

extern crate clap;

extern crate env_logger;

#[macro_use]
extern crate log;

#[macro_use]
extern crate diesel;

#[macro_use]
extern crate juniper;

#[macro_use]
extern crate serde_derive;

extern crate serde_json;

mod app;
mod cli;
mod database_schema;
mod graphql_schema;
mod handlers;
mod models;

use cli::Api;

fn main() {
    Api::start();
}
