use failure::Error;

#[derive(Fail, Debug)]
#[fail(display = "Unknown droplet kind: {}", name)]
struct UnknownDropletKind {
    name: String,
}

#[derive(Debug)]
pub enum DropletKind {
    SecretsKeeper,
}

impl DropletKind {
    pub fn from_name(name: &str) -> Result<Self, Error> {
        match name {
            "secrets_keeper" => Ok(DropletKind::SecretsKeeper),
            _ => Err(UnknownDropletKind {
                name: name.to_string(),
            })?,
        }
    }
}
