module Main exposing (Model, Msg(..), footerLink, init, main, subscriptions, update, view)

import Api.Mutations.SignIn
import Api.Queries.Profile
import Api.Sender
import Browser
import Browser.Navigation
import Copy
import GraphQL.Client.Http as GraphQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Router exposing (Route(..))
import Task exposing (Task)
import Token
import Url



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
    , apiUrl : Maybe Url.Url
    , emailOrUsername : String
    , password : String
    , signInError : Maybe GraphQLClient.Error
    , currentlySigningIn : Bool
    , profileDetails : Maybe Api.Queries.Profile.Profile
    , profileLoadingError : Maybe GraphQLClient.Error
    }



-- TODO: Figure out a way to ensure that routes which require a current user
--       have a way to redirect away


init : Flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            Router.fromUrl url

        apiUrl =
            Url.fromString flags.apiUrl

        cmd =
            cmdForRoute route model

        model =
            Model key url route flags.currentUserToken apiUrl "" "" Nothing False Nothing Nothing
    in
    ( model, cmd )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | EmailOrUsername String
    | Password String
    | AttemptSignIn
    | ReceiveProfileResponse (Result GraphQLClient.Error Api.Queries.Profile.Profile)
    | ReceiveSignInResponse (Result GraphQLClient.Error String)
    | SignOut


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
            let
                route =
                    Router.fromUrl url

                resetModel =
                    { model | url = url, route = route, emailOrUsername = "", password = "", signInError = Nothing, profileLoadingError = Nothing }

                cmd =
                    cmdForRoute route model
            in
            ( resetModel
            , cmd
            )

        EmailOrUsername val ->
            ( { model | emailOrUsername = val }, Cmd.none )

        Password val ->
            ( { model | password = val }, Cmd.none )

        AttemptSignIn ->
            let
                updatedModel =
                    { model | currentlySigningIn = True, signInError = Nothing }

                cmd =
                    withApiUrl model
                        (\apiUrl ->
                            Api.Sender.sendMutationRequest apiUrl
                                model.userToken
                                (Api.Mutations.SignIn.buildRequest model.emailOrUsername model.password)
                                |> Task.attempt ReceiveSignInResponse
                        )
            in
            ( updatedModel, cmd )

        ReceiveProfileResponse result ->
            case result of
                Ok profile ->
                    ( { model | profileDetails = Just profile }, Cmd.none )

                Err e ->
                    ( { model | profileLoadingError = Just e }, Cmd.none )

        ReceiveSignInResponse result ->
            case result of
                Ok token ->
                    ( { model | userToken = Just token, currentlySigningIn = False }
                    , Cmd.batch
                        [ Token.saveToken token
                        , Browser.Navigation.pushUrl model.key "/"
                        ]
                    )

                Err e ->
                    ( { model | signInError = Just e, currentlySigningIn = False }, Cmd.none )

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
    if not (model.route == SignInPage) then
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
                    a [ href "/sign-in" ]
                        [ text "Sign in"
                        ]
            ]

    else
        text ""


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
            div []
                [ p []
                    [ span [] [ text "Please feel free to be in touch. You can follow me at " ]
                    , a [ href "https://twitter.com/maxjacobson" ] [ text "@maxjacobson" ]
                    , span [] [ text " or the project at " ]
                    , a [ href "https://twitter.com/coconut_estate" ] [ text "@coconut_estate" ]
                    , span [] [ text "." ]
                    ]
                ]

        Router.Roadmaps ->
            div [] [ text "TODO: load roadmaps from the API and display them here." ]

        Router.SignInPage ->
            div [ class "sign-in" ]
                [ Html.form [ onSubmit AttemptSignIn ]
                    [ input [ class "emailOrUsername", type_ "text", placeholder "username or email", onInput EmailOrUsername, autofocus True ] []
                    , input [ class "password", type_ "password", placeholder "password", onInput Password ] []
                    , button [ type_ "submit", disabled (cannotAttemptSignIn model) ]
                        [ if model.currentlySigningIn then
                            text "Signing in..."

                          else
                            text "Sign in"
                        ]
                    ]
                , case model.signInError of
                    Just e ->
                        viewGraphQLError e

                    Nothing ->
                        text ""
                ]

        Router.Profile ->
            div []
                [ case model.profileDetails of
                    Just details ->
                        div [ class "profile-details" ]
                            [ p []
                                [ text ("Welcome, " ++ details.name)
                                ]
                            ]

                    Nothing ->
                        case model.profileLoadingError of
                            Just e ->
                                viewGraphQLError e

                            Nothing ->
                                text "Loading..."
                ]

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


cannotAttemptSignIn : Model -> Bool
cannotAttemptSignIn model =
    model.emailOrUsername == "" || model.password == "" || model.currentlySigningIn == True


withApiUrl : Model -> (Url.Url -> Cmd Msg) -> Cmd Msg
withApiUrl model callback =
    case model.apiUrl of
        Just apiUrl ->
            callback apiUrl

        Nothing ->
            Browser.Navigation.pushUrl model.key "/no-api-url-sorry"


viewGraphQLError e =
    case e of
        GraphQLClient.HttpError details ->
            text "Something went wrong with the request. Try again?"

        GraphQLClient.GraphQLError details ->
            ul [] (List.map (\detail -> li [] [ text detail.message ]) details)


cmdForRoute : Route -> Model -> Cmd Msg
cmdForRoute route model =
    case route of
        Router.Profile ->
            withApiUrl model
                (\apiUrl ->
                    Api.Sender.sendQueryRequest apiUrl
                        model.userToken
                        Api.Queries.Profile.buildRequest
                        |> Task.attempt ReceiveProfileResponse
                )

        _ ->
            Cmd.none
