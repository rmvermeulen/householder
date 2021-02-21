module Colors exposing (..)

import Element exposing (rgb)


gray f =
    rgb f f f


white =
    gray 1


black =
    gray 0


red =
    rgb 1 0 0


green =
    rgb 0 1 0


blue =
    rgb 0 0 1
