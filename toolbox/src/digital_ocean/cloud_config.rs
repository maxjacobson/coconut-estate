use failure::Error;
use serde_yaml;

#[derive(Serialize)]
pub struct CloudConfig {
    #[serde(rename = "runcmd")]
    commands: Vec<String>,
    package_upgrade: bool,
    packages: Vec<String>,
    users: Vec<CloudConfigUser>,
}

impl CloudConfig {
    pub fn new() -> CloudConfig {
        CloudConfig {
            commands: vec![],
            package_upgrade: true,
            packages: vec![],
            users: vec![],
        }
    }

    pub fn to_string(&self) -> Result<String, Error> {
        let data = serde_yaml::to_string(self)?;

        debug!("{}", data);

        Ok(format!("#cloud-config\n{}", data))
    }

    pub fn add_user(&mut self, user: CloudConfigUser) {
        self.users.push(user);
    }

    pub fn add_package(&mut self, package: String) {
        self.packages.push(package);
    }

    pub fn add_command(&mut self, command: String) {
        self.commands.push(command);
    }
}

#[derive(Serialize)]
pub struct CloudConfigUser {
    pub name: String,
    pub groups: String,
    pub shell: String,
    pub sudo: Vec<String>,
    #[serde(rename = "ssh-authorized-keys")]
    pub ssh_authorized_keys: Vec<String>,
}
