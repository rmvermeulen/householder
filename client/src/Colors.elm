module Colors exposing (..)

import Element exposing (rgb)


gray : Float -> Element.Color
gray f =
    rgb f f f


white : Element.Color
white =
    gray 1


black : Element.Color
black =
    gray 0


red : Element.Color
red =
    rgb 1 0 0


green : Element.Color
green =
    rgb 0 1 0


blue : Element.Color
blue =
    rgb 0 0 1


purple : Element.Color
purple =
    rgb 1 0 1
