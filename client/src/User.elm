module User exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (custom, required)
import Json.Encode as Encode


type HashedPassword
    = Hex String
    | Raw String


type alias User =
    { id : Int
    , firstName : String
    , lastName : String
    , username : String
    , passwordHash : HashedPassword
    , isActive : Bool
    }


decodeUser : Decoder User
decodeUser =
    let
        hashDecoder : Decoder HashedPassword
        hashDecoder =
            Decode.succeed Hex |> custom Decode.string
    in
    Decode.succeed User
        |> required "id" Decode.int
        |> required "firstName" Decode.string
        |> required "lastName" Decode.string
        |> required "username" Decode.string
        |> required "passwordHash" hashDecoder
        |> required "isActive" Decode.bool


encodeUser : User -> Encode.Value
encodeUser { id, firstName, lastName, isActive } =
    Encode.object
        [ ( "id", Encode.int id )
        , ( "firstName", Encode.string firstName )
        , ( "lastName", Encode.string lastName )
        , ( "isActive", Encode.bool isActive )
        ]
