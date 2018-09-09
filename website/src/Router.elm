module Router exposing (Route(..), fromUrl)

import Url
import Url.Parser exposing ((</>), Parser, oneOf, s, string, top)


type Route
    = Roadmaps
    | About
    | Contact
    | SignInPage
    | Profile
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
        , Url.Parser.map Contact (s "contact")
        , Url.Parser.map SignInPage (s "sign-in")
        , Url.Parser.map Profile (s "profile")
        ]
