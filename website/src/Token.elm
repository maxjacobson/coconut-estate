port module Token exposing (Claims, UserToken, clearToken, decodeClaims, saveToken)

import Base64
import Json.Decode exposing (Decoder, bool, field, int, map2)


type alias UserToken =
    Maybe String


type alias Claims =
    { id : Int
    , siteAdmin : Bool
    }


type DecodeClaimsError
    = InvalidBase64
    | MalformedToken
    | CouldNotDecodeClaimsJSON


decodeClaims : UserToken -> Maybe (Result DecodeClaimsError Claims)
decodeClaims userToken =
    case userToken of
        Just token ->
            case List.head (List.drop 1 (String.split "." token)) of
                Just encodedClaims ->
                    case Base64.decode encodedClaims of
                        Ok json ->
                            case Json.Decode.decodeString claimsDecoder json of
                                Ok claims ->
                                    Just (Ok claims)

                                Err e ->
                                    Just (Err CouldNotDecodeClaimsJSON)

                        Err e ->
                            Just (Err InvalidBase64)

                Nothing ->
                    Just (Err MalformedToken)

        Nothing ->
            Nothing


claimsDecoder : Decoder Claims
claimsDecoder =
    map2 Claims
        (field "id" int)
        (field "site_admin" bool)


port saveToken : String -> Cmd msg


port clearToken : () -> Cmd msg
