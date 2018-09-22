module Views.Profile exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Helpers


view model =
    div []
        [ case model.profileDetails of
            Just result ->
                case result of
                    Ok details ->
                        div [ class "profile-details" ]
                            [ p []
                                [ text ("Welcome, " ++ details.username ++ ".")
                                ]
                            , p []
                                [ if details.emailVerified then
                                    text "Great job, you've verified your email address"

                                  else
                                    span []
                                        [ text "Email not yet verified: "
                                        , code [] [ text details.email ]
                                        , text ". Note: I haven't yet implemented a way for you to verify your email, but ... it's still true, though."
                                        ]
                                ]
                            ]

                    Err e ->
                        Views.Helpers.viewGraphQLError e

            Nothing ->
                text "Loading..."
        ]
