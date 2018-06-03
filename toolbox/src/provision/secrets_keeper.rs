use digital_ocean::Client as DigitalOcean;
use failure::Error;
use psst_helper as psst;
use reqwest;

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

#[derive(Fail, Debug)]
#[fail(display = "Could not create droplet because {:?}", reason)]
struct CouldNotCreateDroplet {
    reason: UnhappyCreateDropletResponse,
}

pub struct Create;

impl Create {
    pub fn run() -> Result<(), Error> {
        debug!("Creating a secrets keeper droplet");
        let digital_ocean_api_key = psst::get("digital_ocean_key")?;

        let mut headers = reqwest::header::Headers::new();
        headers.set(reqwest::header::Authorization(reqwest::header::Bearer {
            token: digital_ocean_api_key.to_string(),
        }));
        headers.set(reqwest::header::ContentType::json());

        let client = DigitalOcean::new()?;
        let deprecated_client = reqwest::Client::builder().default_headers(headers).build()?;

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
                };

                let mut create_droplet_response = deprecated_client
                    .post("https://api.digitalocean.com/v2/droplets")
                    .json(&body)
                    .send()?;

                let status = create_droplet_response.status();
                match status {
                    reqwest::StatusCode::Accepted => {
                        let parsed_create_droplet_response: Result<
                            CreateDropletResponse,
                            reqwest::Error,
                        > = create_droplet_response.json();

                        // TODO: attach a volume, tags, create DNS record, etc...

                        info!("{:#?}", parsed_create_droplet_response);
                    }
                    _ => {
                        let unhappy_create_droplet_response: UnhappyCreateDropletResponse =
                            create_droplet_response.json()?;

                        Err(CouldNotCreateDroplet {
                            reason: unhappy_create_droplet_response,
                        })?
                    }
                }
            }
            Ok(())
        }
    }
}

// TODO: include
//  - backups
//  - private_networking
//  - user_data
//  - monitoring
//  - volumes
//  - tags
#[derive(Debug, Serialize)]
struct CreateDropletBody {
    name: String,
    region: String,
    size: String,
    image: String,
    ssh_keys: Vec<u64>,
}

#[derive(Debug, Deserialize)]
struct CreateDropletResponse {
    droplet: CreatedDroplet,
}

#[derive(Debug, Deserialize)]
struct CreatedDroplet {
    id: u64,
    name: String,
    memory: u64,
    vcpus: u64,
    disk: u64,
    locked: bool,
    created_at: String,
    status: String,
    backup_ids: Vec<u64>,
    snapshot_ids: Vec<u64>,
    features: Vec<String>,
    tags: Vec<String>,
}

#[derive(Debug, Deserialize)]
struct UnhappyCreateDropletResponse {
    id: String,
    message: String,
}
