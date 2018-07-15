use actix_web::{HttpRequest, Json, Result};
use diesel::prelude::*;
use std::env;

use models::Roadmap;
use responses::{RoadmapResponse, RoadmapsResponse};

pub fn list_roadmaps(_data: HttpRequest) -> Result<Json<RoadmapsResponse>> {
    // TODO: figure out a way to manage a connection pool rather than establishing a connection on
    // each request
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    let conn = PgConnection::establish(&database_url)
        .expect(&format!("Error connecting to {}", database_url));

    let roadmaps_list = {
        use database_schema::roadmaps::dsl::*;

        roadmaps.limit(5).load::<Roadmap>(&conn).unwrap()
    };

    Ok(Json(RoadmapsResponse {
        data: roadmaps_list
            .iter()
            .map(|roadmap| RoadmapResponse::new((*roadmap).clone()))
            .collect(),
    }))
}
