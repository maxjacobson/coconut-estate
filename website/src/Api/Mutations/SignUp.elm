module Api.Mutations.SignUp exposing (SignedUpUser, buildRequest)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias SignedUpUser =
    { id : Int }


type alias SignUpVars =
    { email : String, username : String, password : String }


buildRequest email username password =
    mutation
        |> request { email = email, username = username, password = password }



-- HELPERS


mutation : Document Mutation SignedUpUser SignUpVars
mutation =
    let
        emailVar =
            Var.required "email" .email Var.string

        usernameVar =
            Var.required "username" .username Var.string

        passwordVar =
            Var.required "password" .password Var.string

        signedUpUser =
            object SignedUpUser
                |> with (field "id" [] int)
    in
    mutationDocument <|
        extract
            (field "createUser"
                [ ( "email", Arg.variable emailVar )
                , ( "username", Arg.variable usernameVar )
                , ( "password", Arg.variable passwordVar )
                ]
                signedUpUser
            )
