table! {
    roadmaps (id) {
        id -> Int4,
        name -> Varchar,
        created_at -> Timestamp,
        updated_at -> Timestamp,
        author_id -> Int4,
    }
}

table! {
    users (id) {
        id -> Int4,
        email -> Varchar,
        password_hash -> Varchar,
        created_at -> Timestamp,
        updated_at -> Timestamp,
        username -> Varchar,
        email_verified -> Bool,
        site_admin -> Bool,
    }
}

joinable!(roadmaps -> users (author_id));

allow_tables_to_appear_in_same_query!(roadmaps, users,);
