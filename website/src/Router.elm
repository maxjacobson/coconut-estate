module Router exposing (Route(..), fromUrl)

import Api.Queries.AdminUsers
import Api.Queries.Profile
import Api.Queries.Roadmaps
import GraphQL.Client.Http as GraphQLClient
import Url
import Url.Parser exposing ((</>), Parser, oneOf, s, string, top)


type Route
    = Roadmaps (Maybe (Result GraphQLClient.Error (List Api.Queries.Roadmaps.Roadmap)))
    | About
    | AdminUsers (Maybe (Result GraphQLClient.Error (List Api.Queries.AdminUsers.User)))
    | Contact
    | SignInPage SignInDetails
    | SignUpPage SignUpDetails
    | Profile (Maybe (Result GraphQLClient.Error Api.Queries.Profile.Profile))
    | EditProfile EditProfileDetails
    | NewRoadmap NewRoadmapDetails
    | Unknown


fromUrl : Url.Url -> Route
fromUrl url =
    case Url.Parser.parse parse url of
        Just matchingRoute ->
            matchingRoute

        Nothing ->
            Unknown


type alias NewRoadmapDetails =
    { error : Maybe GraphQLClient.Error
    , currentlyAttempting : Bool
    , name : String
    }


type alias SignInDetails =
    { emailOrUsername : String
    , password : String
    , error : Maybe GraphQLClient.Error
    , currentlyAttempting : Bool
    }


type alias SignUpDetails =
    { email : String
    , password : String
    , username : String
    , error : Maybe GraphQLClient.Error
    , currentlyAttempting : Bool
    }


type alias EditProfileDetails =
    { password : String
    }



-- helpers


parse : Parser (Route -> a) a
parse =
    oneOf
        [ Url.Parser.map initRoadmaps top
        , Url.Parser.map About (s "about")
        , Url.Parser.map initAdminUsers (s "admin")
        , Url.Parser.map Contact (s "contact")
        , Url.Parser.map initSignIn (s "sign-in")
        , Url.Parser.map initSignUp (s "sign-up")
        , Url.Parser.map initProfile (s "profile")
        , Url.Parser.map initEditProfile (s "profile" </> s "edit")
        , Url.Parser.map initNewRoadmap (s "roadmaps" </> s "new")
        ]


initRoadmaps =
    Roadmaps Nothing


initAdminUsers =
    AdminUsers Nothing


initSignIn =
    SignInPage
        { emailOrUsername = ""
        , password = ""
        , error = Nothing
        , currentlyAttempting = False
        }


initSignUp =
    SignUpPage
        { email = ""
        , password = ""
        , username = ""
        , error = Nothing
        , currentlyAttempting = False
        }


initProfile =
    Profile Nothing


initEditProfile =
    EditProfile
        { password = "" }


initNewRoadmap =
    NewRoadmap
        { error = Nothing
        , currentlyAttempting = False
        , name = ""
        }
