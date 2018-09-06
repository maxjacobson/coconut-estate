module Main exposing (Model, Msg(..), footerLink, init, main, subscriptions, update, view)

import Browser
import Browser.Navigation
import Copy
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, s, string, top)



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


type Route
    = Roadmaps
    | About
    | Contact
    | Unknown


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Roadmaps top
        , map About (s "about")
        , map Contact (s "contact")
        ]



-- MODEL


type alias Model =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , route : Route
    }


init : () -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    case Url.Parser.parse routeParser url of
        Just matchingRoute ->
            ( Model key url matchingRoute, Cmd.none )

        Nothing ->
            ( Model key url Unknown, Cmd.none )


routeFromUrl url =
    case Url.Parser.parse routeParser url of
        Just matchingRoute ->
            matchingRoute

        Nothing ->
            Unknown



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        UrlChanged url ->
            ( { model | url = url, route = routeFromUrl url }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = Copy.title
    , body =
        [ div [ style "max-width" "640px", style "margin" "0 auto", style "padding" "10px" ]
            [ h1 []
                [ a [ href "/" ] [ text Copy.title ]
                ]
            , renderBody model
            , ul [ style "border-top" "1px solid black", style "list-style-type" "none", style "padding" "0" ]
                [ footerLink "/" "roadmaps"
                , footerLink "/about" "about"
                , footerLink "/contact" "contact"
                ]
            ]
        ]
    }


footerLink : String -> String -> Html msg
footerLink path linkText =
    li [ style "display" "inline", style "margin-right" "5px" ] [ a [ href path ] [ text linkText ] ]


renderBody : Model -> Html msg
renderBody model =
    case model.route of
        About ->
            div [] [ text "The place to go when you're not sure where to even start." ]

        Contact ->
            div [] [ text "Please feel free to be in touch." ]

        Roadmaps ->
            div [] [ text "TODO: load roadmaps from the API and display them here." ]

        Unknown ->
            div [] [ text "Unknown page!" ]