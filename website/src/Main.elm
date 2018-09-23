module Main exposing (Model, Msg(..), footerLink, init, main, subscriptions, update, view)

import Api.Mutations.CreateRoadmap
import Api.Mutations.SignIn
import Api.Mutations.SignUp
import Api.Mutations.UpdateProfile
import Api.Queries.AdminUsers
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
import Router exposing (Route(..))
import Task exposing (Task)
import Token
import Url
import Views.Admin
import Views.Contact
import Views.EditProfile
import Views.Helpers
import Views.NewRoadmap
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
    , signInEmailOrUsername : String
    , signInPassword : String
    , signInError : Maybe GraphQLClient.Error
    , currentlySigningIn : Bool
    , signUpEmail : String
    , signUpPassword : String
    , signUpUsername : String
    , signUpError : Maybe GraphQLClient.Error
    , currentlySigningUp : Bool
    , profileDetails : Maybe (Result GraphQLClient.Error Api.Queries.Profile.Profile)
    , roadmapsList : Maybe (Result GraphQLClient.Error (List Api.Queries.Roadmaps.Roadmap))
    , createRoadmapError : Maybe GraphQLClient.Error
    , currentlyCreatingRoadmap : Bool
    , newRoadmapName : String
    , currentlyUpdatingProfile : Bool
    , editProfilePassword : String
    , updateProfileError : Maybe GraphQLClient.Error
    , adminUsersList : Maybe (Result GraphQLClient.Error (List Api.Queries.AdminUsers.User))
    }



-- TODO: Figure out a way to ensure that routes which require a current user
--       have a way to redirect away


init : Flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
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
            , signInEmailOrUsername = ""
            , signInPassword = ""
            , signInError = Nothing
            , currentlySigningIn = False
            , signUpEmail = ""
            , signUpPassword = ""
            , signUpUsername = ""
            , signUpError = Nothing
            , currentlySigningUp = False
            , profileDetails = Nothing
            , roadmapsList = Nothing
            , createRoadmapError = Nothing
            , currentlyCreatingRoadmap = False
            , newRoadmapName = ""
            , currentlyUpdatingProfile = False
            , editProfilePassword = ""
            , updateProfileError = Nothing
            , adminUsersList = Nothing
            }

        cmd =
            cmdForRoute route model
    in
    ( model, cmd )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | AttemptSignIn
    | AttemptSignUp
    | AttemptCreateRoadmap
    | AttemptUpdateProfile
    | EditProfilePassword String
    | NewRoadmapName String
    | ReceiveAdminUsersResponse (Result GraphQLClient.Error (List Api.Queries.AdminUsers.User))
    | ReceiveCreateRoadmapResponse (Result GraphQLClient.Error Api.Mutations.CreateRoadmap.CreatedRoadmap)
    | ReceiveProfileResponse (Result GraphQLClient.Error Api.Queries.Profile.Profile)
    | ReceiveSignInResponse (Result GraphQLClient.Error String)
    | ReceivePostSignUpSignInResponse (Result GraphQLClient.Error String)
    | ReceiveSignUpResponse (Result GraphQLClient.Error Api.Mutations.SignUp.SignedUpUser)
    | ReceiveRoadmapsListResponse (Result GraphQLClient.Error (List Api.Queries.Roadmaps.Roadmap))
    | ReceiveUpdateProfileResponse (Result GraphQLClient.Error Api.Mutations.UpdateProfile.UpdatedProfile)
    | SignInEmailOrUsername String
    | SignInPassword String
    | SignUpEmail String
    | SignUpPassword String
    | SignUpUsername String
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
                    { model
                        | url = url
                        , route = route
                        , signInEmailOrUsername = ""
                        , signInPassword = ""
                        , signInError = Nothing
                        , roadmapsList = Nothing
                        , profileDetails = Nothing
                        , signUpEmail = ""
                        , signUpPassword = ""
                        , signUpUsername = ""
                        , signUpError = Nothing
                        , newRoadmapName = ""
                        , currentlyCreatingRoadmap = False
                        , createRoadmapError = Nothing
                        , currentlyUpdatingProfile = False
                        , editProfilePassword = ""
                        , updateProfileError = Nothing
                        , adminUsersList = Nothing
                    }

                cmd =
                    cmdForRoute route model
            in
            ( resetModel
            , cmd
            )

        SignInEmailOrUsername val ->
            ( { model | signInEmailOrUsername = val }, Cmd.none )

        SignInPassword val ->
            ( { model | signInPassword = val }, Cmd.none )

        AttemptSignIn ->
            let
                updatedModel =
                    { model | currentlySigningIn = True, signInError = Nothing }

                cmd =
                    Api.Sender.sendMutationRequest model.apiUrl
                        model.userToken
                        (Api.Mutations.SignIn.buildRequest model.signInEmailOrUsername model.signInPassword)
                        |> Task.attempt ReceiveSignInResponse
            in
            ( updatedModel, cmd )

        AttemptSignUp ->
            let
                updatedModel =
                    { model | currentlySigningUp = True, signUpError = Nothing }

                cmd =
                    Api.Sender.sendMutationRequest model.apiUrl
                        model.userToken
                        (Api.Mutations.SignUp.buildRequest model.signUpEmail model.signUpUsername model.signUpPassword)
                        |> Task.attempt ReceiveSignUpResponse
            in
            ( updatedModel, cmd )

        ReceiveAdminUsersResponse result ->
            ( { model | adminUsersList = Just result }, Cmd.none )

        ReceiveProfileResponse result ->
            ( { model | profileDetails = Just result }, Cmd.none )

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

        ReceiveRoadmapsListResponse result ->
            ( { model | roadmapsList = Just result }, Cmd.none )

        SignUpEmail val ->
            ( { model | signUpEmail = val }, Cmd.none )

        SignUpPassword val ->
            ( { model | signUpPassword = val }, Cmd.none )

        SignUpUsername val ->
            ( { model | signUpUsername = val }, Cmd.none )

        ReceivePostSignUpSignInResponse result ->
            case result of
                Ok token ->
                    ( { model | userToken = Just token, currentlySigningIn = False }
                    , Cmd.batch
                        [ Token.saveToken token
                        , Browser.Navigation.pushUrl model.key "/"
                        ]
                    )

                Err e ->
                    ( { model | signInError = Just e, currentlySigningIn = False }
                    , Browser.Navigation.pushUrl model.key "/sign-in"
                    )

        ReceiveSignUpResponse result ->
            case result of
                Ok signedUpUser ->
                    let
                        updatedModel =
                            { model | currentlySigningIn = False }

                        cmd =
                            Api.Sender.sendMutationRequest model.apiUrl
                                model.userToken
                                (Api.Mutations.SignIn.buildRequest model.signUpEmail model.signUpPassword)
                                |> Task.attempt ReceivePostSignUpSignInResponse
                    in
                    ( updatedModel, cmd )

                Err e ->
                    ( { model | signUpError = Just e, currentlySigningUp = False }, Cmd.none )

        ReceiveCreateRoadmapResponse result ->
            case result of
                Ok createdRoadmap ->
                    let
                        updatedModel =
                            { model | currentlyCreatingRoadmap = False }

                        cmd =
                            Browser.Navigation.pushUrl model.key "/"
                    in
                    ( updatedModel, cmd )

                Err e ->
                    ( { model | createRoadmapError = Just e, currentlyCreatingRoadmap = False }, Cmd.none )

        ReceiveUpdateProfileResponse result ->
            case result of
                Ok updatedProfile ->
                    let
                        updatedModel =
                            { model | currentlyUpdatingProfile = False }

                        cmd =
                            Browser.Navigation.pushUrl model.key "/profile"
                    in
                    ( updatedModel, cmd )

                Err e ->
                    ( { model | updateProfileError = Just e, currentlyUpdatingProfile = False }, Cmd.none )

        SignOut ->
            ( { model | userToken = Nothing }
            , Cmd.batch
                [ Token.clearToken ()
                , Browser.Navigation.pushUrl model.key "/sign-in"
                ]
            )

        AttemptCreateRoadmap ->
            let
                updatedModel =
                    { model | currentlyCreatingRoadmap = True, createRoadmapError = Nothing }

                cmd =
                    Api.Sender.sendMutationRequest model.apiUrl
                        model.userToken
                        (Api.Mutations.CreateRoadmap.buildRequest model.newRoadmapName)
                        |> Task.attempt ReceiveCreateRoadmapResponse
            in
            ( updatedModel, cmd )

        NewRoadmapName name ->
            ( { model | newRoadmapName = name }, Cmd.none )

        EditProfilePassword password ->
            ( { model | editProfilePassword = password }, Cmd.none )

        AttemptUpdateProfile ->
            let
                updatedModel =
                    { model | currentlyUpdatingProfile = True, updateProfileError = Nothing }

                cmd =
                    Api.Sender.sendMutationRequest model.apiUrl
                        model.userToken
                        (Api.Mutations.UpdateProfile.buildRequest model.editProfilePassword)
                        |> Task.attempt ReceiveUpdateProfileResponse
            in
            ( updatedModel, cmd )



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
            [ div [ class "everything-but-footer" ]
                [ viewHeader model
                , viewBody model
                ]
            , viewFooter model
            ]
        ]
    }


viewHeader : Model -> Html Msg
viewHeader model =
    div [ class "top-of-web-page" ]
        [ header []
            [ if model.route == Router.Roadmaps then
                h1 [] [ text Copy.headerTitle ]

              else
                h1 [] [ a [ href "/" ] [ text Copy.headerTitle ] ]
            ]
        , div [ class "sign-in-cta-or-profile" ]
            [ case model.userToken of
                Just token ->
                    div []
                        [ span [ class "profile-link" ]
                            [ a [ href "/profile", class (routeActiveHtmlClass [ Router.Profile, Router.EditProfile ] model.route) ]
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
                        [ a [ href "/sign-in", class "sign-in-link", class (routeActiveHtmlClass [ Router.SignInPage ] model.route) ]
                            [ text "Sign in"
                            ]
                        , span [] [ text ", " ]
                        , a [ href "/sign-up", class "sign-up-link", class (routeActiveHtmlClass [ Router.SignUpPage ] model.route) ]
                            [ text "Sign up" ]
                        ]
            ]
        ]


viewBody : Model -> Html Msg
viewBody model =
    case model.route of
        Router.About ->
            div []
                [ h2 [] [ text "About" ]
                , p []
                    [ text "The place to go when you're not sure where to even start."
                    ]
                ]

        Router.AdminUsers ->
            Views.Admin.view model

        Router.Contact ->
            Views.Contact.view model

        Router.Roadmaps ->
            Views.RoadmapsList.view model

        Router.SignInPage ->
            Views.SignIn.view model AttemptSignIn SignInEmailOrUsername SignInPassword

        Router.SignUpPage ->
            Views.SignUp.view model AttemptSignUp SignUpEmail SignUpPassword SignUpUsername

        Router.Profile ->
            Views.Profile.view model

        Router.EditProfile ->
            Views.EditProfile.view model AttemptUpdateProfile EditProfilePassword

        Router.NewRoadmap ->
            Views.NewRoadmap.view model AttemptCreateRoadmap NewRoadmapName

        Router.Unknown ->
            div [] [ text "Unknown page!" ]


viewFooter : Model -> Html Msg
viewFooter model =
    footer []
        [ ul []
            [ footerLink "/" "roadmaps" [ Router.Roadmaps, Router.NewRoadmap ] model.route
            , footerLink "/about" "about" [ Router.About ] model.route
            , footerLink "/contact" "contact" [ Router.Contact ] model.route
            , case Token.decodeClaims model.userToken of
                Just (Ok claims) ->
                    if claims.siteAdmin == True then
                        footerLink "/admin" "admin" [ Router.AdminUsers ] model.route

                    else
                        text ""

                Just (Err e) ->
                    text ""

                Nothing ->
                    text ""
            ]
        ]


footerLink : String -> String -> List Route -> Route -> Html Msg
footerLink path linkText targetRouteFamily currentRoute =
    let
        anchorClass =
            routeActiveHtmlClass targetRouteFamily currentRoute
    in
    li [] [ a [ href path, class anchorClass ] [ text linkText ] ]


routeActiveHtmlClass : List Route -> Route -> String
routeActiveHtmlClass targetRouteFamily currentRoute =
    if List.member currentRoute targetRouteFamily then
        "active"

    else
        ""


cmdForRoute : Route -> Model -> Cmd Msg
cmdForRoute route model =
    case route of
        -- Load users list when visiting admin users page
        Router.AdminUsers ->
            Api.Sender.sendQueryRequest model.apiUrl
                model.userToken
                Api.Queries.AdminUsers.buildListRequest
                |> Task.attempt ReceiveAdminUsersResponse

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

        Router.SignInPage ->
            redirectIfAlreadyLoggedIn model

        Router.SignUpPage ->
            redirectIfAlreadyLoggedIn model

        -- Don't do anything special when visiting other pages
        _ ->
            Cmd.none


redirectIfAlreadyLoggedIn model =
    case model.userToken of
        Just token ->
            Browser.Navigation.pushUrl model.key "/"

        Nothing ->
            Cmd.none
