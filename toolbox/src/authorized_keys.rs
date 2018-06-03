use authorized_keys_generator::Generator as GitHubKeys;
use failure::Error;

#[derive(Fail, Debug)]
#[fail(display = "Can't sync keys from GitHub because there aren't any")]
struct NoKeysOnGitHub;

static USERNAMES: &'static [&str] = &["maxjacobson"];
use digital_ocean::Client as DigitalOcean;

pub struct App;
impl App {
    pub fn new() -> App {
        App
    }

    pub fn run(&self) -> Result<(), Error> {
        let digital_ocean_client = DigitalOcean::new()?;
        let digital_ocean_ssh_keys = digital_ocean_client.list_ssh_keys()?;
        let usernames: Vec<&str> = USERNAMES.into_iter().map(|s| *s).collect();
        let github_keys = GitHubKeys::new(usernames)?;

        if github_keys.keys.len() == 0 {
            Err(NoKeysOnGitHub)?;
        }

        for gh_key in &github_keys.keys {
            if !digital_ocean_ssh_keys
                .iter()
                .any(|digital_ocean_key| digital_ocean_key.public_key == gh_key.public_key)
            {
                digital_ocean_client.create_ssh_key(
                    &format!("From GitHub user @{}", gh_key.username),
                    &gh_key.public_key,
                )?;
            }
        }

        for digital_ocean_key in digital_ocean_ssh_keys {
            if !github_keys
                .keys
                .iter()
                .any(|gh_key| gh_key.public_key == digital_ocean_key.public_key)
            {
                digital_ocean_client.delete_ssh_key(&digital_ocean_key)?;
            }
        }

        Ok(())
    }
}
