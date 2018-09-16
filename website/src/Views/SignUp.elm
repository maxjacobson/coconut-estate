module Views.SignUp exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Views.Helpers


view model submitEvent emailMessage passwordMessage usernameMessage =
    div [ class "sign-up" ]
        [ Html.form [ onSubmit submitEvent ]
            [ input [ class "email", type_ "text", placeholder "email", onInput emailMessage, autofocus True ] []
            , input [ class "username", type_ "text", placeholder "username", onInput usernameMessage ] []
            , input [ class "password", type_ "password", placeholder "password", onInput passwordMessage ] []
            , button [ type_ "submit", disabled (cannotAttemptSignUp model) ]
                [ if model.currentlySigningUp then
                    text "Signing up..."

                  else
                    text "Sign up"
                ]
            ]
        , case model.signUpError of
            Just e ->
                Views.Helpers.viewGraphQLError e

            Nothing ->
                text ""
        ]



-- HELPERS


cannotAttemptSignUp model =
    model.signUpEmail
        == ""
        || model.signUpUsername
        == ""
        || model.signUpPassword
        == ""
        || model.currentlySigningUp
        == True
