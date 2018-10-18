module Copy exposing (headerTitle, title)

import Router exposing (Route(..))


title : Route -> String
title route =
    let
        prefix =
            case route of
                Roadmaps list ->
                    "roadmaps"

                About ->
                    "about"

                AdminUsers list ->
                    "users - admin"

                Contact ->
                    "contact"

                SignInPage details ->
                    "sign-in"

                SignUpPage details ->
                    "sign-up"

                Profile profile ->
                    "profile"

                EditProfile details ->
                    "edit profile"

                NewRoadmap details ->
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
