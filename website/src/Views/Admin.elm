module Views.Admin exposing (view)

import Html exposing (..)
import Html.Attributes exposing (href)
import Views.Helpers


view model =
    div []
        [ h2 [] [ text "Admin" ]
        , p [] [ text "Welcome to the admin section." ]
        , h3 [] [ text "Users" ]
        , case model.adminUsersList of
            Just result ->
                case result of
                    Ok users ->
                        case users of
                            [] ->
                                p [] [ text "none yet!" ]

                            _ ->
                                table []
                                    [ thead []
                                        [ tr []
                                            [ th [] [ text "id" ]
                                            , th [] [ text "username" ]
                                            , th [] [ text "email" ]
                                            ]
                                        ]
                                    , tbody []
                                        (List.map
                                            (\user ->
                                                tr []
                                                    [ td [] [ text (String.fromInt user.id) ]
                                                    , td [] [ text user.username ]
                                                    , td [] [ text user.email ]
                                                    ]
                                            )
                                            users
                                        )
                                    ]

                    Err e ->
                        Views.Helpers.viewGraphQLError e

            Nothing ->
                p [] [ text "Loading users..." ]
        ]
