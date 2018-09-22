port module Token exposing (UserToken, clearToken, saveToken)


type alias UserToken =
    Maybe String


port saveToken : String -> Cmd msg


port clearToken : () -> Cmd msg
