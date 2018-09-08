module Main exposing (Model, Msg(..), footerLink, init, main, subscriptions, update, view)

import Browser
import Browser.Navigation
import Copy
import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Router exposing (Route(..))
import Task exposing (Task)
import Token
import Url
import User exposing (User)



-- MAIN


type alias SignInVars =
    { emailOrUsername : String, password : String }


signInMutation : Document Mutation String SignInVars
signInMutation =
    let
        emailOrUsernameVar =
            Var.required "emailOrUsername" .emailOrUsername Var.string

        passwordVar =
            Var.required "password" .password Var.string
    in
    mutationDocument <|
        extract
            (field "signIn"
                [ ( "emailOrUsername", Arg.variable emailOrUsernameVar )
                , ( "password", Arg.variable passwordVar )
                ]
                (extract (field "token" [] string))
            )


signInMutationRequest : String -> String -> Request Mutation String
signInMutationRequest emailOrUsername password =
    signInMutation
        |> request { emailOrUsername = emailOrUsername, password = password }



-- type alias SignInResponse =


sendMutationRequest : Url.Url -> Request Mutation a -> Task GraphQLClient.Error a
sendMutationRequest apiUrl request =
    GraphQLClient.sendMutation (Url.toString apiUrl) request


type alias UserToken =
    Maybe String


type alias Flags =
    { currentUserToken : UserToken, apiUrl : String }


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
    , userToken : UserToken
    , apiUrl : Maybe Url.Url
    , emailOrUsername : String
    , password : String
    , signInError : Maybe GraphQLClient.Error
    , currentlySigningIn : Bool
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
    in
    ( Model key url route flags.currentUserToken apiUrl "" "" Nothing False, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | EmailOrUsername String
    | Password String
    | AttemptSignIn
    | ReceiveSignInResponse (Result GraphQLClient.Error String)


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
            -- reset things
            ( { model | url = url, route = Router.fromUrl url, emailOrUsername = "", password = "", signInError = Nothing }
            , Cmd.none
            )

        EmailOrUsername val ->
            ( { model | emailOrUsername = val }, Cmd.none )

        Password val ->
            ( { model | password = val }, Cmd.none )

        AttemptSignIn ->
            case model.apiUrl of
                Just apiUrl ->
                    ( { model | currentlySigningIn = True }
                    , sendMutationRequest apiUrl
                        (signInMutationRequest model.emailOrUsername model.password)
                        |> Task.attempt ReceiveSignInResponse
                    )

                Nothing ->
                    ( model, Browser.Navigation.pushUrl model.key "/no-api-url-sorry" )

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
                        [ span [ class "profile-link" ] [ text "Profile" ]
                        , span [ class "sign-out-link" ] [ text "Sign out" ]
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
            div [] [ text "Please feel free to be in touch." ]

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
                        text "Some error huh"

                    Nothing ->
                        text ""
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
            if targetRoute == currentRoute then
                "active"

            else
                ""
    in
    li [] [ a [ href path, class anchorClass ] [ text linkText ] ]


cannotAttemptSignIn : Model -> Bool
cannotAttemptSignIn model =
    model.emailOrUsername == "" || model.password == "" || model.currentlySigningIn == True
