module Views.Helpers exposing (viewGraphQLError)

import GraphQL.Client.Http as GraphQLClient
import Html exposing (..)


viewGraphQLError e =
    case e of
        GraphQLClient.HttpError details ->
            text "Something went wrong with the request. Try again?"

        GraphQLClient.GraphQLError details ->
            ul [] (List.map (\detail -> li [] [ text detail.message ]) details)
