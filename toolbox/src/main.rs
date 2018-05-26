#[macro_use]
extern crate clap;

extern crate failure;
#[macro_use]
extern crate failure_derive;

extern crate env_logger;

extern crate psst;

extern crate reqwest;

mod clap_helpers;
mod cli;
mod droplet_kinds;
mod environments;
mod provision;
mod psst_helper;
mod secrets;

fn print_fail(fail: &failure::Fail) {
    println!("fail: {:#?}", fail);

    if let Some(cause) = fail.cause() {
        print_fail(cause);
    }
}

fn print_err(err: failure::Error) {
    let cause: &failure::Fail = err.cause();
    print_fail(cause);
}

fn main() {
    env_logger::init();
    match cli::App::new().run() {
        Err(err) => {
            print_err(err);

            // while let Some(cause) = fail.cause() {
            //     println!("{}", cause);

            //     fail = cause;
            // } else {
        }
        _ => {}
    }
}
