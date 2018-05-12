use failure::Error;

#[derive(Fail, Debug)]
#[fail(display = "An error occurred.")]
struct MyCliError;

pub struct App;

impl App {
    pub fn new() -> Self {
        App
    }

    pub fn run(&self) -> Result<(), Error> {
        Err(MyCliError)?
    }
}
