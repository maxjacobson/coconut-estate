module Views.Contact exposing (view)

import Html exposing (..)
import Html.Attributes exposing (href)


view model =
    div []
        [ h2 [] [ text "Contact" ]
        , p []
            [ span [] [ text "Please feel free to be in touch. You can follow me at " ]
            , a [ href "https://twitter.com/maxjacobson" ] [ text "@maxjacobson" ]
            , span [] [ text " or the project at " ]
            , a [ href "https://twitter.com/coconut_estate" ] [ text "@coconut_estate" ]
            , span [] [ text "." ]
            ]
        ]
