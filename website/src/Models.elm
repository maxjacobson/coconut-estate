module Models exposing (SignIn, initSignIn, withSignIn)

import GraphQL.Client.Http as GraphQLClient


type alias SignIn =
    { emailOrUsername : String
    , password : String
    , error : Maybe GraphQLClient.Error
    , inProgress : Bool
    }


initSignIn : SignIn
initSignIn =
    { emailOrUsername = ""
    , password = ""
    , error = Nothing
    , inProgress = False
    }


withSignIn model callback =
    let
        signIn =
            model.signIn

        updatedSignIn =
            callback signIn
    in
    { model | signIn = updatedSignIn }
