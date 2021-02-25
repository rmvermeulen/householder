module Pages.Home exposing (..)

import Chore
import Element exposing (..)
import Element.Background as Background
import Framework.Color as Color
import Grid
import Table exposing (Table)


view remap { size, chores } =
    row
        [ padding 16
        , Background.color Color.white
        , width fill
        , height fill
        ]
        [ chores
            |> List.map
                (\chore ->
                    Chore.view chore
                        |> remap chore.id
                )
            |> Grid.view (max 1 (size.x // 200))
                [ fillPortion 8
                    |> minimum (min size.x 800)
                    |> maximum 1200
                    |> width
                , padding 10
                , spacing 10
                ]
                (always [ width (px 200), height (px 120) ])
        , el [ width fill, height fill ]
            none
        ]
