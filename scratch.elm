module Main exposing (Model)


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
