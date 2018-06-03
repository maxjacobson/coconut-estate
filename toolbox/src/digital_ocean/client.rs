use failure::Error;
use psst_helper as psst;
use reqwest::{self, StatusCode};

#[derive(Fail, Debug)]
#[fail(display = "Could not {} because {} ({:?})", action, status, details)]
struct UnexpectedStatusCode {
    status: StatusCode,
    action: String,
    details: UnhappyCreateDropletResponse,
}

pub struct Client {
    http: reqwest::Client,
}

impl Client {
    pub fn new() -> Result<Self, Error> {
        let digital_ocean_api_key = psst::get("digital_ocean_key")?;

        let mut headers = reqwest::header::Headers::new();
        headers.set(reqwest::header::Authorization(reqwest::header::Bearer {
            token: digital_ocean_api_key.to_string(),
        }));
        headers.set(reqwest::header::ContentType::json());

        Ok(Self {
            http: reqwest::Client::builder().default_headers(headers).build()?,
        })
    }

    pub fn list_droplets(&self, tag_name: &str) -> Result<Droplets, Error> {
        let mut response = self.http
            .get("https://api.digitalocean.com/v2/droplets")
            .query(&[("tag_name", tag_name)])
            .send()?;

        let status = response.status();
        if status == StatusCode::Ok {
            let droplets: Droplets = response.json()?;
            Ok(droplets)
        } else {
            let details: UnhappyCreateDropletResponse = response.json()?;
            Err(UnexpectedStatusCode {
                action: "Listing droplets".to_string(),
                status: status,
                details: details,
            })?
        }
    }

    pub fn create_ssh_key(&self, name: &str, public_key: &str) -> Result<SshKey, Error> {
        let body = CreateSshKey {
            name: name.to_string(),
            public_key: public_key.to_string(),
        };
        let mut response = self.http
            .post("https://api.digitalocean.com/v2/account/keys")
            .json(&body)
            .send()?;

        let status = response.status();
        // N.B., this might return a 422 if the SSH key already exists.
        // If that happens, the only way to unblock currently is to delete the SSH key from
        // Digital Ocean and try again ...
        // Probably an opportunity for improvement somehow
        if status == StatusCode::Created {
            let created_key: CreatedSshKey = response.json()?;
            debug!("Created key {:?}", name);
            Ok(created_key.ssh_key)
        } else {
            let details: UnhappyCreateDropletResponse = response.json()?;
            Err(UnexpectedStatusCode {
                action: "Fetch SSH keys from Digital Ocean".to_string(),
                status: status,
                details: details,
            })?
        }
    }

    pub fn delete_ssh_key(&self, ssh_key: &SshKey) -> Result<(), Error> {
        debug!("Deleting ssh key {}", ssh_key.name);

        let mut response = self.http
            .delete(&format!(
                "https://api.digitalocean.com/v2/account/keys/{}",
                ssh_key.id
            ))
            .send()?;

        let status = response.status();
        if status == StatusCode::NoContent {
            Ok(())
        } else {
            let details: UnhappyCreateDropletResponse = response.json()?;
            Err(UnexpectedStatusCode {
                action: "Delete SSH key from Digital Ocean".to_string(),
                status: status,
                details: details,
            })?
        }
    }

    pub fn list_ssh_keys(&self) -> Result<Vec<SshKey>, Error> {
        let mut result = vec![];

        let mut url = "https://api.digitalocean.com/v2/account/keys".to_string();

        loop {
            let mut response = self.http.get(&url).send()?;
            let status = response.status();
            if status == StatusCode::Ok {
                let ssh_keys: SshKeys = response.json()?;

                for ssh_key in ssh_keys.ssh_keys {
                    result.push(ssh_key);
                }

                if let Some(pages) = ssh_keys.links.pages {
                    url = pages.next;
                } else {
                    break;
                }
            } else {
                let details: UnhappyCreateDropletResponse = response.json()?;
                Err(UnexpectedStatusCode {
                    action: "Fetch SSH keys from Digital Ocean".to_string(),
                    status: status,
                    details: details,
                })?
            }
        }

        Ok(result)
    }
}

#[derive(Debug, Deserialize)]
struct SshKeys {
    ssh_keys: Vec<SshKey>,
    links: Links,
}

#[derive(Debug, Deserialize)]
pub struct SshKey {
    pub id: u64,
    fingerprint: String,
    pub public_key: String,
    name: String,
}

#[derive(Debug, Deserialize)]
struct Links {
    pages: Option<Pages>,
}

#[derive(Debug, Deserialize)]
struct Pages {
    last: String,
    next: String,
}

#[derive(Debug, Deserialize)]
struct UnhappyCreateDropletResponse {
    id: String,
    message: String,
}

#[derive(Debug, Serialize)]
struct CreateSshKey {
    name: String,
    public_key: String,
}

// Response to creating an SSH key
#[derive(Debug, Deserialize)]
struct CreatedSshKey {
    ssh_key: SshKey,
}

#[derive(Deserialize, Debug)]
pub struct Droplets {
    pub droplets: Vec<Droplet>,
}

// TODO: add volume_ids
#[derive(Deserialize, Debug)]
pub struct Droplet {
    id: u64,
    features: Vec<String>,
    name: String,
    status: String,
    networks: Networks,
}

#[derive(Deserialize, Debug)]
struct Networks {
    v4: Vec<V4Network>,
}

#[derive(Deserialize, Debug)]
struct V4Network {
    ip_address: String,
    netmask: String,
    gateway: String,
}
