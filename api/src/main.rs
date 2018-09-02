extern crate actix_web;

extern crate chrono;

extern crate clap;

extern crate env_logger;

#[macro_use]
extern crate log;

#[macro_use]
extern crate diesel;

extern crate jsonwebtoken;

#[macro_use]
extern crate juniper;

extern crate libpasta;

extern crate r2d2;

#[macro_use]
extern crate serde_derive;

extern crate serde_json;

mod app;
mod auth;
mod cli;
mod database;
mod database_schema;
mod graphql;
mod graphql_schema;
mod handlers;
mod mutations;
mod queries;

use cli::Api;

fn main() {
    Api::start();
}
