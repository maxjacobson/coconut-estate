module Views.RoadmapsList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Views.Helpers


view model =
    div [ class "roadmaps-list" ]
        [ h2 [] [ text "Roadmaps" ]
        , case model.roadmapsList of
            Just result ->
                case result of
                    Ok roadmaps ->
                        ul []
                            (List.map
                                (\roadmap ->
                                    li [] [ text roadmap.name ]
                                )
                                roadmaps
                            )

                    Err e ->
                        Views.Helpers.viewGraphQLError e

            Nothing ->
                text "Loading..."
        ]
