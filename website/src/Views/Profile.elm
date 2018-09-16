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
                                [ text ("Welcome, " ++ details.username)
                                ]
                            ]

                    Err e ->
                        Views.Helpers.viewGraphQLError e

            Nothing ->
                text "Loading..."
        ]
