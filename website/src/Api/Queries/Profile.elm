module Api.Queries.Profile exposing (Profile, buildRequest)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias Profile =
    { name : String
    , username : String
    , email : String
    }


type alias UserVars =
    {}


buildRequest : Request Query Profile
buildRequest =
    query |> request {}



-- HELPERS


query : Document Query Profile UserVars
query =
    let
        user =
            object Profile
                |> with (field "name" [] string)
                |> with (field "username" [] string)
                |> with (field "email" [] string)

        queryRoot =
            extract (field "user" [] user)
    in
    queryDocument queryRoot
