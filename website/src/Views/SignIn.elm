module Views.SignIn exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Views.Helpers


view details submitMessage emailOrUsernameMessage passwordMessage =
    div [ class "sign-in" ]
        [ Html.form [ onSubmit submitMessage ]
            [ input [ class "emailOrUsername", type_ "text", placeholder "username or email", onInput emailOrUsernameMessage, autofocus True ] []
            , input [ class "password", type_ "password", placeholder "password", onInput passwordMessage ] []
            , button [ type_ "submit", disabled (cannotAttemptSignIn details) ]
                [ if details.currentlyAttempting then
                    text "Signing in..."

                  else
                    text "Sign in"
                ]
            ]
        , case details.error of
            Just e ->
                Views.Helpers.viewGraphQLError e

            Nothing ->
                text ""
        ]



-- HELPERS


cannotAttemptSignIn details =
    details.emailOrUsername
        == ""
        || details.password
        == ""
        || details.currentlyAttempting
        == True
