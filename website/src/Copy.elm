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

                SignUpPage ->
                    "sign-up"

                Profile ->
                    "profile"

                EditProfile ->
                    "edit profile"

                NewRoadmap ->
                    "add a new roadmap"

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
