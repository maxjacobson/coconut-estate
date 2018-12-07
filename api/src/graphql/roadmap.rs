use crate::database;
use chrono::NaiveDateTime;
use std::convert::From;

#[derive(GraphQLObject)]
#[graphql(description = "A plan to follow")]
pub struct Roadmap {
    pub created_at: NaiveDateTime,
    pub id: i32,
    pub name: String,
    pub updated_at: NaiveDateTime,
}

impl From<database::Roadmap> for Roadmap {
    fn from(roadmap: database::Roadmap) -> Roadmap {
        Roadmap {
            created_at: roadmap.created_at,
            id: roadmap.id,
            name: roadmap.name,
            updated_at: roadmap.updated_at,
        }
    }
}

impl<'a> From<&'a database::Roadmap> for Roadmap {
    fn from(roadmap: &database::Roadmap) -> Roadmap {
        Roadmap {
            created_at: roadmap.created_at,
            id: roadmap.id,
            name: roadmap.name.clone(),
            updated_at: roadmap.updated_at,
        }
    }
}
