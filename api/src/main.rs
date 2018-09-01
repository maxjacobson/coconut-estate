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

extern crate libpasta;

#[macro_use]
extern crate serde_derive;

extern crate serde_json;

extern crate jsonwebtoken;

mod app;
mod auth;
mod cli;
mod database_schema;
mod graphql_schema;
mod handlers;
mod models;

use cli::Api;

fn main() {
    Api::start();
}
