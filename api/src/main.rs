#[macro_use]
extern crate diesel;

#[macro_use]
extern crate juniper;

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

use crate::cli::Api;

fn main() {
    Api::start();
}
