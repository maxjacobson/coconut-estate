module Messages.SignIn exposing (SignIn(..), update)

import Api.Mutations.SignIn
import Api.Sender
import Browser.Navigation
import GraphQL.Client.Http as GraphQLClient
import Models
import Task
import Token


type SignIn
    = EmailOrUsername String
    | Password String
    | Attempt
    | ReceiveResponse (Result GraphQLClient.Error String)


update model msg =
    case msg of
        EmailOrUsername val ->
            let
                updatedModel =
                    Models.withSignIn model
                        (\signIn ->
                            { signIn | emailOrUsername = val }
                        )
            in
            ( updatedModel, Cmd.none )

        Password val ->
            let
                updatedModel =
                    Models.withSignIn model
                        (\signIn ->
                            { signIn | password = val }
                        )
            in
            ( updatedModel, Cmd.none )

        Attempt ->
            let
                updatedModel =
                    Models.withSignIn model
                        (\signIn ->
                            { signIn | inProgress = True, error = Nothing }
                        )

                cmd =
                    Api.Sender.sendMutationRequest model.apiUrl
                        model.userToken
                        (Api.Mutations.SignIn.buildRequest model.signIn)
                        |> Task.attempt ReceiveResponse
            in
            ( updatedModel, cmd )

        ReceiveResponse result ->
            case result of
                Ok token ->
                    let
                        updatedModel =
                            Models.withSignIn { model | userToken = Just token }
                                (\signIn ->
                                    { signIn | inProgress = False }
                                )
                    in
                    ( updatedModel
                    , Cmd.batch
                        [ Token.saveToken token
                        , Browser.Navigation.pushUrl model.key "/"
                        ]
                    )

                Err e ->
                    let
                        updatedModel =
                            Models.withSignIn model
                                (\signIn ->
                                    { signIn | error = Just e, inProgress = False }
                                )
                    in
                    ( updatedModel, Nothing )
