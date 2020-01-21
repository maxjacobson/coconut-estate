module Views.RoadmapsList exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Views.Helpers


view model list =
    div [ class "roadmaps-list" ]
        [ h2 [] [ text "Roadmaps" ]
        , addRoadmap model
        , case list of
            Just result ->
                case result of
                    Ok roadmaps ->
                        case roadmaps of
                            [] ->
                                p [] [ text "None yet!" ]

                            _ ->
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
                ul []
                    [ li [] [ text "..." ]
                    , li [] [ text "..." ]
                    , li [] [ text "..." ]
                    ]
        ]


addRoadmap model =
    case model.userToken of
        Just token ->
            div [ class "add-roadmap-link" ]
                [ a [ href "/roadmaps/new" ] [ text "Add roadmap" ]
                ]

        Nothing ->
            text ""
