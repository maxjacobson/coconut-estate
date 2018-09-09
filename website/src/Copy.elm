module Copy exposing (headerTitle, title)

import Router exposing (Route(..))


title : Route -> String
title route =
    let
        prefix =
            case route of
                Roadmaps ->
                    "roadmaps"

                About ->
                    "about"

                Contact ->
                    "contact"

                SignInPage ->
                    "sign-in"

                Profile ->
                    "profile"

                Unknown ->
                    "???"
    in
    prefix ++ " - " ++ productName


headerTitle : String
headerTitle =
    productName



-- HELPERS


productName =
    "coconut estate"
