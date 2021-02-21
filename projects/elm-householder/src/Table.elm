module Table exposing (..)

import Dict exposing (Dict)


type Id data
    = Id Int


type Table data
    = Table Int (Dict Int data)


fromList : List data -> Table data
fromList list =
    let
        addRec : List data -> Int -> Dict Int data -> Dict Int data
        addRec items id dict =
            case items of
                first :: rest ->
                    addRec rest (id + 1) (Dict.insert id first dict)

                _ ->
                    dict
    in
    Table (List.length list) (addRec list 0 Dict.empty)


empty : Table data
empty =
    Table 0 Dict.empty


add : data -> Table data -> ( Id data, Table data )
add data (Table id dict) =
    let
        newDict =
            Dict.insert id data dict
    in
    ( Id id, Table (id + 1) newDict )


get : Id data -> Table data -> Maybe data
get (Id id) (Table _ dict) =
    Dict.get id dict


remove : Id info -> Table info -> Table info
remove (Id id) (Table nextId dict) =
    Table nextId (Dict.remove id dict)


replace : Id data -> data -> Table data -> Table data
replace (Id id) data (Table storeId dict) =
    if Dict.member id dict then
        Table storeId (Dict.insert id data dict)

    else
        Table storeId dict


member : Id data -> Table data -> Bool
member (Id id) (Table _ dict) =
    Dict.member id dict


size : Table data -> Int
size (Table _ dict) =
    Dict.size dict


values : Table data -> List data
values (Table _ dict) =
    Dict.values dict


pairs : Table data -> List ( Id data, data )
pairs store =
    rawPairs store
        |> List.map (Tuple.mapFirst Id)


rawPairs : Table data -> List ( Int, data )
rawPairs (Table _ dict) =
    Dict.toList dict


map : (Id data -> data -> data) -> Table data -> Table data
map fn (Table storeId storeDict) =
    let
        mapper id value dict =
            Dict.insert id (fn (Id id) value) dict

        newDict =
            Dict.foldl mapper Dict.empty storeDict
    in
    Table storeId newDict


mapSingle : Id data -> (data -> data) -> Table data -> Table data
mapSingle (Id id) fn (Table storeId storeDict) =
    Dict.get id storeDict
        |> Maybe.map (\value -> Dict.insert id (fn value) storeDict)
        |> Maybe.withDefault storeDict
        |> Table storeId
