module Household exposing (..)

import Time


type User
    = User


type Status
    = Todo
    | Done
    | Planned
    | Disabled


type alias Task =
    { id : Int
    , status : Status
    , title : String
    , description : String
    }


createTask : String -> String -> Task
createTask title description =
    Task 0 Todo title description
