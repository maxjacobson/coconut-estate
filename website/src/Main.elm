module Main exposing (Model, Msg(..), footerLink, init, main, subscriptions, update, view)

import Browser
import Browser.Navigation
import Copy
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, s, string, top)
import User exposing (User)



-- MAIN


main : Program (Maybe String) Model Msg
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
    , user : Maybe User
    }


init : Maybe String -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            routeFromUrl url

        user =
            User.load flags
    in
    ( Model key url route user, Cmd.none )


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
        [ div [ class "body" ]
            [ renderSignin model
            , renderTitle model
            , renderBody model
            , renderFooter model
            ]
        ]
    }


renderSignin : Model -> Html msg
renderSignin model =
    div [ class "sign-in" ]
        [ case model.user of
            Just user ->
                text ("Welcome " ++ user.username)

            Nothing ->
                text "Sign in?"
        ]


renderTitle : Model -> Html msg
renderTitle model =
    h1 [] [ a [ href "/" ] [ text Copy.title ] ]


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


renderFooter : Model -> Html msg
renderFooter model =
    footer []
        [ ul []
            [ footerLink "/" "roadmaps" Roadmaps model.route
            , footerLink "/about" "about" About model.route
            , footerLink "/contact" "contact" Contact model.route
            ]
        ]


footerLink : String -> String -> Route -> Route -> Html msg
footerLink path linkText targetRoute currentRoute =
    let
        anchorClass =
            if targetRoute == currentRoute then
                "active"

            else
                ""
    in
    li [] [ a [ href path, class anchorClass ] [ text linkText ] ]
