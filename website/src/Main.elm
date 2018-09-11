module Main exposing (Model, Msg(..), footerLink, init, main, subscriptions, update, view)

import Api.Mutations.SignUp
import Api.Queries.Profile
import Api.Queries.Roadmaps
import Api.Sender
import Browser
import Browser.Navigation
import Copy
import GraphQL.Client.Http as GraphQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Messages.SignIn
import Models
import Router exposing (Route(..))
import Task exposing (Task)
import Token
import Url
import Views.Contact
import Views.Helpers
import Views.Profile
import Views.RoadmapsList
import Views.SignIn
import Views.SignUp



-- MAIN


type alias Flags =
    { currentUserToken : Token.UserToken, apiUrl : String }


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
    , userToken : Token.UserToken
    , apiUrl : String
    , signIn : Models.SignIn
    , signUpEmail : String
    , signUpName : String
    , signUpPassword : String
    , signUpUsername : String
    , signUpError : Maybe GraphQLClient.Error
    , currentlySigningUp : Bool
    , profileDetails : Maybe (Result GraphQLClient.Error Api.Queries.Profile.Profile)
    , roadmapsList : Maybe (Result GraphQLClient.Error (List Api.Queries.Roadmaps.Roadmap))
    }



-- TODO: Figure out a way to ensure that routes which require a current user
--       have a way to redirect away


init : Flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd msg )
init flags url key =
    let
        route =
            Router.fromUrl url

        model =
            { key = key
            , url = url
            , route = route
            , userToken = flags.currentUserToken
            , apiUrl = flags.apiUrl
            , signIn = Models.initSignIn
            , signUpEmail = ""
            , signUpName = ""
            , signUpPassword = ""
            , signUpUsername = ""
            , signUpError = Nothing
            , currentlySigningUp = False
            , profileDetails = Nothing
            , roadmapsList = Nothing
            }

        cmd =
            cmdForRoute route model
    in
    ( model, cmd )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | AttemptSignUp
    | ReceiveProfileResponse (Result GraphQLClient.Error Api.Queries.Profile.Profile)
    | ReceiveSignUpResponse (Result GraphQLClient.Error Api.Mutations.SignUp.SignedUpUser)
    | ReceiveRoadmapsListResponse (Result GraphQLClient.Error (List Api.Queries.Roadmaps.Roadmap))
    | SignInMessage Messages.SignIn.SignIn
    | SignUpEmail String
    | SignUpName String
    | SignUpPassword String
    | SignUpUsername String
    | SignOut


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Browser.Navigation.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Browser.Navigation.load href )

        UrlChanged url ->
            let
                route =
                    Router.fromUrl url

                resetModel =
                    { model
                        | url = url
                        , route = route
                        , signIn = Models.initSignIn
                        , roadmapsList = Nothing
                        , profileDetails = Nothing
                        , signUpEmail = ""
                        , signUpName = ""
                        , signUpPassword = ""
                        , signUpUsername = ""
                        , signUpError = Nothing
                    }

                cmd =
                    cmdForRoute route model
            in
            ( resetModel
            , cmd
            )

        SignInMessage signInMsg ->
            -- Messages.SignIn.update model signInMsg
            case Messages.SignIn.update model signInMsg of
                ( updatedModel, Just task ) ->
                    ( updatedModel, task |> Task.attempt )

        AttemptSignUp ->
            let
                updatedModel =
                    { model | currentlySigningUp = True, signUpError = Nothing }

                cmd =
                    Api.Sender.sendMutationRequest model.apiUrl
                        model.userToken
                        (Api.Mutations.SignUp.buildRequest model.signUpEmail model.signUpName model.signUpUsername model.signUpPassword)
                        |> Task.attempt ReceiveSignUpResponse
            in
            ( updatedModel, cmd )

        ReceiveProfileResponse result ->
            ( { model | profileDetails = Just result }, Cmd.none )

        ReceiveRoadmapsListResponse result ->
            ( { model | roadmapsList = Just result }, Cmd.none )

        SignUpEmail val ->
            ( { model | signUpEmail = val }, Cmd.none )

        SignUpName val ->
            ( { model | signUpName = val }, Cmd.none )

        SignUpPassword val ->
            ( { model | signUpPassword = val }, Cmd.none )

        SignUpUsername val ->
            ( { model | signUpUsername = val }, Cmd.none )

        ReceiveSignUpResponse result ->
            case result of
                Ok signedUpUser ->
                    ( { model | currentlySigningUp = False }, Browser.Navigation.pushUrl model.key "/sign-in" )

                Err e ->
                    ( { model | signUpError = Just e, currentlySigningUp = False }, Cmd.none )

        SignOut ->
            ( { model | userToken = Nothing }
            , Cmd.batch
                [ Token.clearToken "please, friend"
                , Browser.Navigation.pushUrl model.key "/sign-in"
                ]
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = Copy.title model.route
    , body =
        [ div [ class "body" ]
            [ viewSignin model
            , viewTitle model
            , viewBody model
            , viewFooter model
            ]
        ]
    }


viewSignin : Model -> Html Msg
viewSignin model =
    div [ class "sign-in-cta-or-profile" ]
        [ case model.userToken of
            Just token ->
                div []
                    [ span [ class "profile-link" ]
                        [ a [ href "/profile", class (routeActiveHtmlClass Router.Profile model.route) ]
                            [ text "Profile"
                            ]
                        ]
                    , span [ class "sign-out-link" ]
                        [ button [ onClick SignOut ]
                            [ text "Sign out"
                            ]
                        ]
                    ]

            Nothing ->
                -- TODO: figure out a way to avoid the duplication in providing
                -- an href here and then the same value in the Router module
                div []
                    [ a [ href "/sign-in", class "sign-in-link", class (routeActiveHtmlClass Router.SignInPage model.route) ]
                        [ text "Sign in"
                        ]
                    , span [] [ text ", " ]
                    , a [ href "/sign-up", class "sign-up-link", class (routeActiveHtmlClass Router.SignUpPage model.route) ]
                        [ text "Sign up" ]
                    ]
        ]


viewTitle : Model -> Html Msg
viewTitle model =
    header []
        [ if model.route == Router.Roadmaps then
            h1 [] [ text Copy.headerTitle ]

          else
            h1 [] [ a [ href "/" ] [ text Copy.headerTitle ] ]
        ]


viewBody : Model -> Html Msg
viewBody model =
    case model.route of
        Router.About ->
            div [] [ text "The place to go when you're not sure where to even start." ]

        Router.Contact ->
            Views.Contact.view model

        Router.Roadmaps ->
            Views.RoadmapsList.view model

        Router.SignInPage ->
            Views.SignIn.view model.signIn Messages.SignIn.Attempt Messages.SignIn.EmailOrUsername Messages.SignIn.Password

        Router.SignUpPage ->
            Views.SignUp.view model AttemptSignUp SignUpEmail SignUpName SignUpPassword SignUpUsername

        Router.Profile ->
            Views.Profile.view model

        Router.Unknown ->
            div [] [ text "Unknown page!" ]


viewFooter : Model -> Html Msg
viewFooter model =
    footer []
        [ ul []
            [ footerLink "/" "roadmaps" Router.Roadmaps model.route
            , footerLink "/about" "about" Router.About model.route
            , footerLink "/contact" "contact" Router.Contact model.route
            ]
        ]


footerLink : String -> String -> Route -> Route -> Html Msg
footerLink path linkText targetRoute currentRoute =
    let
        anchorClass =
            routeActiveHtmlClass targetRoute currentRoute
    in
    li [] [ a [ href path, class anchorClass ] [ text linkText ] ]


routeActiveHtmlClass : Route -> Route -> String
routeActiveHtmlClass targetRoute currentRoute =
    if targetRoute == currentRoute then
        "active"

    else
        ""


cmdForRoute : Route -> Model -> Cmd msg
cmdForRoute route model =
    case route of
        -- Load user profile when visiting profile page
        Router.Profile ->
            Api.Sender.sendQueryRequest model.apiUrl
                model.userToken
                Api.Queries.Profile.buildRequest
                |> Task.attempt ReceiveProfileResponse

        -- Load roadmaps list when visiting roadmaps list page
        Router.Roadmaps ->
            Api.Sender.sendQueryRequest model.apiUrl
                model.userToken
                Api.Queries.Roadmaps.buildListRequest
                |> Task.attempt ReceiveRoadmapsListResponse

        -- Redirect away if already logged in
        Router.SignInPage ->
            case model.userToken of
                Just token ->
                    Browser.Navigation.pushUrl model.key "/"

                Nothing ->
                    Cmd.none

        -- Redirect away if already logged in
        Router.SignUpPage ->
            case model.userToken of
                Just token ->
                    Browser.Navigation.pushUrl model.key "/"

                Nothing ->
                    Cmd.none

        -- Don't do anything special when visiting other pages
        _ ->
            Cmd.none
