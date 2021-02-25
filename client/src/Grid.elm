module Grid exposing (..)

import Element exposing (..)


view : Int -> List (Attribute msg) -> (( Int, Int ) -> List (Attribute msg)) -> List (Element msg) -> Element msg
view colCount attrs getChildAttrs children =
    let
        indexed =
            children
                |> List.indexedMap Tuple.pair
                |> List.map (Tuple.mapFirst (\n -> n // colCount))

        rows =
            let
                firstEquals n =
                    Tuple.first >> (==) n
            in
            List.range 0 (List.length children)
                |> List.map (\i -> List.filter (firstEquals i) indexed)
                |> List.map (List.map Tuple.second)
                |> List.indexedMap
                    (\y group ->
                        let
                            withAttrs x child =
                                el (getChildAttrs ( x, y )) child
                        in
                        group |> List.indexedMap withAttrs
                    )
                |> List.map (row [ width fill, height fill ])
    in
    column attrs rows
