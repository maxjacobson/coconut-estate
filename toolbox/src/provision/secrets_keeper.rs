use digital_ocean::{Client as DigitalOcean, CreateDropletBody, CreateVolumeBody};
use failure::Error;

static TAG_NAME: &'static str = "secrets-keeper";
static EXPECTED_COUNT: usize = 1; // Who needs more than one?
static DEFAULT_REGION: &'static str = "nyc1"; // I <3 NY
static DEFAULT_SIZE: &'static str = "s-1vcpu-1gb"; // the cheap one
static DEFAULT_IMAGE: &'static str = "ubuntu-16-04-x64"; // Just copied from the examples, unclear where else to find this slug...

#[derive(Fail, Debug)]
#[fail(display = "There are more secrets keeper droplets than I expected ({})", count)]
struct UnexpectedlyTooManyDroplets {
    count: usize,
}

pub struct Create;

impl Create {
    pub fn run() -> Result<(), Error> {
        debug!("Creating a secrets keeper droplet");
        let client = DigitalOcean::new()?;

        let droplets_response = client.list_droplets(TAG_NAME)?;

        let count = droplets_response.droplets.len();
        if count == EXPECTED_COUNT {
            info!("No need to provision anything, since it already exists");
            Ok(())
        } else if count > EXPECTED_COUNT {
            Err(UnexpectedlyTooManyDroplets { count })?
        } else {
            for i in 1..=EXPECTED_COUNT {
                info!("Creating droplet #{}", i);

                let created_volume = client.create_volume(&CreateVolumeBody {
                    size_gigabytes: 1,
                    name: format!("secrets-keeper-{}", i),
                    description: Some(format!(
                        "Volume to store secrets on for secrets-keeper-{}",
                        i
                    )),
                    region: DEFAULT_REGION.to_string(),
                })?;

                let body = CreateDropletBody {
                    name: format!("secrets-keeper-{}", i),
                    region: DEFAULT_REGION.to_string(),
                    size: DEFAULT_SIZE.to_string(),
                    image: DEFAULT_IMAGE.to_string(),
                    ssh_keys: client
                        .list_ssh_keys()?
                        .iter()
                        .map(|ssh_key| ssh_key.id)
                        .collect(),
                    tags: Some(vec![TAG_NAME.to_string()]),
                    volumes: Some(vec![created_volume.volume.id]),
                };

                client.create_droplet(&body)?;
            }
            Ok(())
        }
    }
}
