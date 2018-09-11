module Api.Mutations.SignIn exposing (buildRequest)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias SignInVars =
    { emailOrUsername : String, password : String }


buildRequest signIn =
    mutation
        |> request { emailOrUsername = signIn.emailOrUsername, password = signIn.password }



-- HELPERS


mutation : Document Mutation String SignInVars
mutation =
    let
        emailOrUsernameVar =
            Var.required "emailOrUsername" .emailOrUsername Var.string

        passwordVar =
            Var.required "password" .password Var.string
    in
    mutationDocument <|
        extract
            (field "signIn"
                [ ( "emailOrUsername", Arg.variable emailOrUsernameVar )
                , ( "password", Arg.variable passwordVar )
                ]
                (extract (field "token" [] string))
            )
