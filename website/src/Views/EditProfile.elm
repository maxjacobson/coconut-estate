module Views.EditProfile exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onSubmit)
import Views.Helpers


view model submitEvent passwordMessage =
    div [ class "edit-profile" ]
        [ Html.form [ onSubmit submitEvent ]
            [ input [ class "password", type_ "password", placeholder "new password", onInput passwordMessage ] []
            , button [ type_ "submit", disabled (cannotAttemptEditProfile model), class "update-profile-button" ]
                [ if model.currentlyUpdatingProfile then
                    text "Updating..."

                  else
                    text "Update"
                ]
            ]
        , case model.updateProfileError of
            Just e ->
                Views.Helpers.viewGraphQLError e

            Nothing ->
                text ""
        ]



-- HELPERS


cannotAttemptEditProfile model =
    model.currentlyUpdatingProfile || model.editProfilePassword == ""
