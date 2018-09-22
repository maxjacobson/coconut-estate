module Router exposing (Route(..), fromUrl)

import Url
import Url.Parser exposing ((</>), Parser, oneOf, s, string, top)


type Route
    = Roadmaps
    | About
    | Admin
    | Contact
    | SignInPage
    | SignUpPage
    | Profile
    | EditProfile
    | NewRoadmap
    | Unknown


fromUrl : Url.Url -> Route
fromUrl url =
    case Url.Parser.parse parse url of
        Just matchingRoute ->
            matchingRoute

        Nothing ->
            Unknown



-- helpers


parse : Parser (Route -> a) a
parse =
    oneOf
        [ Url.Parser.map Roadmaps top
        , Url.Parser.map About (s "about")
        , Url.Parser.map Admin (s "admin")
        , Url.Parser.map Contact (s "contact")
        , Url.Parser.map SignInPage (s "sign-in")
        , Url.Parser.map SignUpPage (s "sign-up")
        , Url.Parser.map Profile (s "profile")
        , Url.Parser.map EditProfile (s "profile" </> s "edit")
        , Url.Parser.map NewRoadmap (s "roadmaps" </> s "new")
        ]
