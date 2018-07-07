use chrono::NaiveDateTime;

#[derive(Clone, Debug, Queryable, Serialize)]
pub struct Roadmap {
    pub id: i32,
    pub name: String,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
}
