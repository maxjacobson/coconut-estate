module Views.NewRoadmap exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Views.Helpers


view model submitMessage nameMessage =
    div [ class "new-roadmap" ]
        [ h2 [] [ text "New roadmap" ]
        , Html.form [ onSubmit submitMessage ]
            [ input [ class "name", type_ "text", placeholder "name", onInput nameMessage, autofocus True ] []
            , button [ type_ "submit", disabled (cannotAttemptCreate model), class "create-roadmap-button" ]
                [ if model.currentlyCreatingRoadmap then
                    text "Creating..."

                  else
                    text "Create"
                ]
            ]
        , case model.createRoadmapError of
            Just e ->
                Views.Helpers.viewGraphQLError e

            Nothing ->
                text ""
        ]



-- HELPERS


cannotAttemptCreate model =
    model.newRoadmapName == "" || model.currentlyCreatingRoadmap == True
