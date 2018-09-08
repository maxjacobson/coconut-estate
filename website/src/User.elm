module User exposing (User, load)

import Maybe exposing (map2)
import Url


type alias User =
    { token : String
    , username : String
    , email : String
    }


load : Maybe String -> Maybe Url.Url -> Maybe User
load token apiUrl =
    -- lol this feels weird but I want to flatten a doubly-nested Maybe into a
    -- singly-nested one and this works.
    map2 loadWithRealToken token apiUrl |> Maybe.andThen identity



-- HELPERS


loadWithRealToken : String -> Url.Url -> Maybe User
loadWithRealToken token apiUrl =
    -- TODO: use token to look up real details
    -- TODO: or is this wrong and I should be using Cmd/Task somehow?
    -- TODO: Maybe this should actually return a Result? I guess decide that later.
    Just (User "abdef" "maxjacobson" "max@example.com")


identity a =
    a
