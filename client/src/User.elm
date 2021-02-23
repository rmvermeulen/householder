module User exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


type alias User =
    { id : Int
    , firstName : String
    , lastName : String
    , isActive : Bool
    }


decodeUser : Decoder User
decodeUser =
    Decode.succeed User
        |> required "id" Decode.int
        |> required "firstName" Decode.string
        |> required "lastName" Decode.string
        |> required "isActive" Decode.bool


encodeUser : User -> Encode.Value
encodeUser { id, firstName, lastName, isActive } =
    Encode.object
        [ ( "id", Encode.int id )
        , ( "firstName", Encode.string firstName )
        , ( "lastName", Encode.string lastName )
        , ( "isActive", Encode.bool isActive )
        ]
