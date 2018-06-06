use digital_ocean::{Client as DigitalOcean, CreateDropletBody, CreateVolumeBody};
use digital_ocean::{CloudConfig, CloudConfigUser};
use failure::Error;

static TAG_NAME: &'static str = "secrets-keeper";
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
        if count == 1 {
            info!("No need to provision anything, since it already exists");
            Ok(())
        } else if count > 1 {
            Err(UnexpectedlyTooManyDroplets { count })?
        } else {
            info!("Creating secrets-keeper droplet");

            // N.B. here we're unconditionally creating the volume, but if we ever later on
            // want to provision a new secrets keeper and move the volume from the old one to
            // the new one, we'll need to update this (and the user_data shell script)
            let created_volume = client.create_volume(&CreateVolumeBody {
                size_gigabytes: 1,
                name: "secrets-keeper".to_string(),
                description: Some(String::from(
                    "Volume to store secrets on for secrets-keeper",
                )),
                region: DEFAULT_REGION.to_string(),
            })?;

            let ssh_keys: Vec<(u64, String)> = client
                .list_ssh_keys()?
                .iter()
                .map(|ssh_key| (ssh_key.id, ssh_key.public_key.clone()))
                .collect();

            let body = CreateDropletBody {
                name: String::from("secrets-keeper"),
                region: DEFAULT_REGION.to_string(),
                size: DEFAULT_SIZE.to_string(),
                image: DEFAULT_IMAGE.to_string(),
                ssh_keys: ssh_keys.iter().map(|pair| pair.0).collect(),
                tags: Some(vec![TAG_NAME.to_string()]),
                user_data: Some(Self::user_data(
                    ssh_keys.iter().map(|pair| pair.1.clone()).collect(),
                )?),
                volumes: Some(vec![created_volume.volume.id]),
            };

            client.create_droplet(&body)?;
            Ok(())
        }
    }

    fn user_data(ssh_keys: Vec<String>) -> Result<String, Error> {
        let mut user_data = CloudConfig::new();
        user_data.add_user(CloudConfigUser {
            name: "coconut".to_string(),
            groups: "sudo".to_string(),
            shell: "/bin/bash".to_string(),
            sudo: vec!["ALL=(ALL) NOPASSWD:ALL".to_string()],
            ssh_authorized_keys: ssh_keys,
        });

        user_data.add_package("htop".to_string());
        user_data.add_package("jq".to_string());
        user_data.add_package("ncdu".to_string());
        user_data.add_package("tree".to_string());

        // Via
        // https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04
        user_data.add_command("sudo ufw allow OpenSSH".to_string());
        user_data.add_command("sudo ufw enable".to_string());

        // Via in-app "Config instructions" on volume page
        user_data.add_command(
            "sudo mkfs.ext4 -F /dev/disk/by-id/scsi-0DO_Volume_secrets-keeper".to_string(),
        );
        user_data.add_command("mkdir -p /mnt/secrets-keeper".to_string());
        user_data.add_command("mount -o discard,defaults /dev/disk/by-id/scsi-0DO_Volume_secrets-keeper /mnt/secrets-keeper".to_string());
        user_data.add_command("echo /dev/disk/by-id/scsi-0DO_Volume_secrets-keeper /mnt/secrets-keeper ext4 defaults,nofail,discard 0 0 | sudo tee -a /etc/fstab".to_string());
        user_data.add_command("sudo chown coconut:coconut /mnt/secrets-keeper".to_string());

        user_data.to_string()
    }
}
