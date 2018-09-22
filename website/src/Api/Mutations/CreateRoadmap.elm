module Api.Mutations.CreateRoadmap exposing (CreatedRoadmap, buildRequest)

import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias CreatedRoadmap =
    { id : Int }


type alias CreateRoadmapVars =
    { name : String }


buildRequest name =
    mutation
        |> request { name = name }



-- HELPERS


mutation : Document Mutation CreatedRoadmap CreateRoadmapVars
mutation =
    let
        nameVar =
            Var.required "name" .name Var.string

        createdRoadmap =
            object CreatedRoadmap
                |> with (field "id" [] int)
    in
    mutationDocument <|
        extract
            (field "createRoadmap"
                [ ( "name", Arg.variable nameVar )
                ]
                createdRoadmap
            )
