#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub id: i32,
    pub site_admin: bool,
}
