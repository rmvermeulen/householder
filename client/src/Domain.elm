module Domain exposing (..)

import Binary
import SHA
import User exposing (HashedPassword(..))


type Api
    = Mocked
    | Server


type alias Size t =
    { x : t, y : t }


hashPassword : String -> HashedPassword
hashPassword =
    Binary.fromStringAsUtf8
        >> SHA.sha256
        >> Binary.toHex
        >> Hex


find : (item -> Bool) -> List item -> Maybe item
find pred =
    List.filter pred >> List.head
