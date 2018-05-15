use failure::Error;

pub struct Create;

impl Create {
    pub fn run() -> Result<(), Error> {
        println!("Creating a secrets keeper droplet");

        Ok(())
    }
}
