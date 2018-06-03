// This bin is just meant to serve as an example of how you might use this as a library
//
// Usage:
// bin/authorized-keys-generator --usernames username1 username2 username3
extern crate authorized_keys_generator;
use authorized_keys_generator::Generator;

#[macro_use]
extern crate clap;
use clap::{App, Arg};

extern crate env_logger;

fn main() {
    env_logger::init();

    let matches = App::new("authorized keys generator")
        .about("CLI for generating an authorized keys file based on a list of GitHub users")
        .version(crate_version!())
        .arg(
            Arg::with_name("usernames")
                .short("u")
                .long("usernames")
                .multiple(true)
                .takes_value(true)
                .required(true),
        )
        .get_matches();

    if let Some(raw_usernames) = matches.values_of("usernames") {
        println!(
            "{}",
            Generator::new(raw_usernames.collect())
                .expect("Couldn't fetch keys")
                .authorized_keys_format()
        );
    } else {
        panic!("Whaaat?");
    }
}
