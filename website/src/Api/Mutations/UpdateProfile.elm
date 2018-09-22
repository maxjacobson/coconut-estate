module Api.Mutations.UpdateProfile exposing (UpdatedProfile, buildRequest)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias UpdatedProfile =
    { id : Int }


type alias UpdateProfileVars =
    { password : String }


buildRequest password =
    mutation
        |> request { password = password }



-- HELPERS


mutation : Document Mutation UpdatedProfile UpdateProfileVars
mutation =
    let
        passwordVar =
            Var.required "password" .password Var.string

        updatedProfile =
            object UpdatedProfile
                |> with (field "id" [] int)
    in
    mutationDocument <|
        extract
            (field "updateUser"
                [ ( "password", Arg.variable passwordVar )
                ]
                updatedProfile
            )
