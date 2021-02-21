module Household exposing (..)

import Time


type User
    = User


type Status
    = Todo
    | Done
    | Disabled
    | Planned


nextStatus status =
    case status of
        Todo ->
            Done

        Done ->
            Disabled

        Disabled ->
            Planned

        Planned ->
            Todo


type alias Task =
    { status : Status
    , title : String
    , description : String
    , deadline : Maybe Time.Posix
    }


createTask title description =
    Task Todo title description Nothing
