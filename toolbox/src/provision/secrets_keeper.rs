use failure::Error;
use psst_helper as psst;
use reqwest;

pub struct Create;

impl Create {
    pub fn run() -> Result<(), Error> {
        println!("Creating a secrets keeper droplet");
        let digital_ocean_api_key = psst::get("digital_ocean_key")?;

        println!(
            "Successfully retrieved Digital Ocean key: {}",
            digital_ocean_api_key
        );

        let body = reqwest::get("https://www.hardscrabble.net")?.text()?;

        println!("{}", body);

        Ok(())
    }
}
