module Views.SignIn exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Views.Helpers


view model submitMessage emailOrUsernameMessage passwordMessage =
    div [ class "sign-in" ]
        [ Html.form [ onSubmit submitMessage ]
            [ input [ class "emailOrUsername", type_ "text", placeholder "username or email", onInput emailOrUsernameMessage, autofocus True ] []
            , input [ class "password", type_ "password", placeholder "password", onInput passwordMessage ] []
            , button [ type_ "submit", disabled (cannotAttemptSignIn model) ]
                [ if model.currentlySigningIn then
                    text "Signing in..."

                  else
                    text "Sign in"
                ]
            ]
        , case model.signInError of
            Just e ->
                Views.Helpers.viewGraphQLError e

            Nothing ->
                text ""
        ]



-- HELPERS


cannotAttemptSignIn model =
    model.signInEmailOrUsername
        == ""
        || model.signInPassword
        == ""
        || model.currentlySigningIn
        == True
