module Api.Sender exposing (sendMutationRequest, sendQueryRequest)

import GraphQL.Client.Http as GraphQLClient
import GraphQL.Request.Builder exposing (..)
import Http
import Task exposing (Task)
import Token
import Url


sendMutationRequest : Url.Url -> Token.UserToken -> Request Mutation a -> Task GraphQLClient.Error a
sendMutationRequest apiUrl token request =
    GraphQLClient.customSendMutation (requestOptions apiUrl token) request


sendQueryRequest : Url.Url -> Token.UserToken -> Request Query a -> Task GraphQLClient.Error a
sendQueryRequest apiUrl token request =
    GraphQLClient.customSendQuery (requestOptions apiUrl token) request



-- HELPERS


requestOptions apiUrl token =
    { method = "POST"
    , headers = headers token
    , url = Url.toString apiUrl
    , timeout = Nothing
    , withCredentials = False
    }


headers token =
    case token of
        Just val ->
            [ Http.header "Authorization" ("Bearer: " ++ val)
            ]

        Nothing ->
            []
