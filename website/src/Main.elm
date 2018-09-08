module Main exposing (Model, Msg(..), footerLink, init, main, subscriptions, update, view)

import Browser
import Browser.Navigation
import Copy
import Html exposing (..)
import Html.Attributes exposing (..)
import Router exposing (Route(..))
import Url
import User exposing (User)



-- MAIN


type alias Flags =
    Maybe String


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



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
            Router.fromUrl url

        user =
            User.load flags
    in
    ( Model key url route user, Cmd.none )



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
            ( { model | url = url, route = Router.fromUrl url }
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
            [ viewSignin model
            , viewTitle model
            , viewBody model
            , viewFooter model
            ]
        ]
    }


viewSignin : Model -> Html msg
viewSignin model =
    div [ class "sign-in" ]
        [ case model.user of
            Just user ->
                text ("Welcome " ++ user.username)

            Nothing ->
                text "Sign in?"
        ]


viewTitle : Model -> Html msg
viewTitle model =
    h1 [] [ a [ href "/" ] [ text Copy.title ] ]


viewBody : Model -> Html msg
viewBody model =
    case model.route of
        Router.About ->
            div [] [ text "The place to go when you're not sure where to even start." ]

        Router.Contact ->
            div [] [ text "Please feel free to be in touch." ]

        Router.Roadmaps ->
            div [] [ text "TODO: load roadmaps from the API and display them here." ]

        Router.Unknown ->
            div [] [ text "Unknown page!" ]


viewFooter : Model -> Html msg
viewFooter model =
    footer []
        [ ul []
            [ footerLink "/" "roadmaps" Router.Roadmaps model.route
            , footerLink "/about" "about" Router.About model.route
            , footerLink "/contact" "contact" Router.Contact model.route
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
