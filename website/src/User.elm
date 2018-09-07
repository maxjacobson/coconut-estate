module User exposing (User, load)

import Maybe exposing (andThen)


type alias User =
    { token : String
    , username : String
    , email : String
    }


load : Maybe String -> Maybe User
load maybe_token =
    maybe_token |> andThen loadWithRealToken


loadWithRealToken : String -> Maybe User
loadWithRealToken token =
    -- TODO: use token to look up real details
    -- TODO: or is this wrong and I should be using Cmd/Task somehow?
    Just (User "abdef" "maxjacobson" "max@example.com")
