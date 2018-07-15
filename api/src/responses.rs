use models::Roadmap;

#[derive(Serialize)]
pub struct RoadmapResponse {
    attributes: Roadmap,
    id: i32,
    #[serde(rename = "type")]
    kind: String,
}

impl RoadmapResponse {
    pub fn new(roadmap: Roadmap) -> Self {
        RoadmapResponse {
            id: roadmap.id,
            attributes: roadmap,
            kind: "roadmap".to_string(),
        }
    }
}

#[derive(Serialize)]
pub struct RoadmapsResponse {
    pub data: Vec<RoadmapResponse>,
}
