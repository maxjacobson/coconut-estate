module Api.Queries.Roadmaps exposing (Roadmap, buildListRequest)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg


type alias Roadmap =
    { id : Int, name : String }


buildListRequest : Request Query (List Roadmap)
buildListRequest =
    listQuery |> request {}



-- HELPERS


listQuery : Document Query (List Roadmap) {}
listQuery =
    let
        roadmap =
            object Roadmap
                |> with (field "id" [] int)
                |> with (field "name" [] string)

        queryRoot =
            extract (field "roadmaps" [] (list roadmap))
    in
    queryDocument queryRoot
