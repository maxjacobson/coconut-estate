port module Token exposing (clearToken, saveToken)


port saveToken : String -> Cmd msg


port clearToken : String -> Cmd msg
