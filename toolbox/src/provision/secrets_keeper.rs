use failure::Error;
use psst_helper as psst;
use reqwest;

use std::collections::HashMap;

pub struct Create;

impl Create {
    pub fn run() -> Result<(), Error> {
        info!("Creating a secrets keeper droplet");
        let digital_ocean_api_key = psst::get("digital_ocean_key")?;

        // TODO: extract the digital ocean client somewhere re-usable
        let mut headers = reqwest::header::Headers::new();
        headers.set(reqwest::header::Authorization(format!(
            "Bearer {}",
            digital_ocean_api_key
        )));
        let client = reqwest::Client::builder().default_headers(headers).build()?;

        let mut map = HashMap::new();
        map.insert("lang", "rust");
        map.insert("body", "json");
        let response = client.post("http://httpbin.org/post").json(&map).send()?;

        println!("{:#?}", response);

        Ok(())
    }
}
