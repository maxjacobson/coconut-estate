module User exposing (User, load)


type alias User =
    { token : String
    , username : String
    , email : String
    }


load : Maybe String -> Maybe User
load maybe_token =
    case maybe_token of
        Just token ->
            loadWithRealToken token

        Nothing ->
            Nothing


loadWithRealToken : String -> Maybe User
loadWithRealToken token =
    -- TODO: use token to look up real details
    Just (User "abdef" "maxjacobson" "max@example.com")
