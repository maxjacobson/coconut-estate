module Api.Queries.AdminUsers exposing (User, buildListRequest)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg


type alias User =
    { id : Int, username : String, email : String }


buildListRequest : Request Query (List User)
buildListRequest =
    listQuery |> request {}



-- HELPERS


listQuery : Document Query (List User) {}
listQuery =
    let
        user =
            object User
                |> with (field "id" [] int)
                |> with (field "username" [] string)
                |> with (field "email" [] string)

        queryRoot =
            extract (field "users" [] (list user))
    in
    queryDocument queryRoot
