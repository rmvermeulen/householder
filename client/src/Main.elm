module Main exposing (..)

import Browser
import Colors
import Debug
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Household
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Json.Encode as Encode
import Table exposing (..)
import Theme



---- MODEL ----


type LayoutMode
    = Mobile
    | Wide
    | Centered


layoutName layout =
    case layout of
        Mobile ->
            "Mobile"

        Wide ->
            "Wide"

        Centered ->
            "Centered"


type alias Model =
    { layoutMode : LayoutMode
    , tasks : Table Household.Task
    , mText : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    ( { layoutMode = Centered
      , tasks =
            Table.fromList
                [ Household.createTask
                    "Some task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Another task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Another task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Another task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Another task"
                    "This is just for testing. Don't worry about it."
                ]
      , mText = Nothing
      }
    , Cmd.batch [ Http.get { url = "http://localhost:4000", expect = Http.expectString ServerMessage } ]
    )



---- UPDATE ----


type alias TaskId =
    Table.Id Household.Task


type Msg
    = SetLayoutMode LayoutMode
    | AddTask Household.Task
    | TaskSetTitle TaskId String
    | TaskSetDescription TaskId String
    | TaskSetStatus TaskId Household.Status
    | ServerMessage (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        simply m =
            ( m, Cmd.none )
    in
    case msg of
        SetLayoutMode mode ->
            simply { model | layoutMode = mode }

        AddTask task ->
            simply { model | tasks = Table.add task model.tasks |> Tuple.second }

        TaskSetTitle id title ->
            let
                tasks =
                    Table.mapSingle id (\task -> { task | title = title }) model.tasks
            in
            simply { model | tasks = tasks }

        TaskSetDescription id description ->
            let
                tasks =
                    Table.mapSingle id (\task -> { task | description = description }) model.tasks
            in
            simply { model | tasks = tasks }

        TaskSetStatus id status ->
            let
                tasks =
                    Table.mapSingle id (\task -> { task | status = status }) model.tasks
            in
            simply { model | tasks = tasks }

        ServerMessage result ->
            let
                string =
                    case result of
                        Ok s ->
                            Debug.log "Received" s

                        Err e ->
                            Debug.log "Error" (Debug.toString e)

                itemDecoder : Decoder MyObject
                itemDecoder =
                    Decode.succeed MyObject
                        |> required "data" Decode.bool
                        |> required "value" Decode.int
                        |> required "fields" (Decode.list Decode.string)

                listDecoder =
                    Decode.list itemDecoder

                values : List MyObject
                values =
                    case Decode.decodeString listDecoder string of
                        Ok v ->
                            v

                        Err e ->
                            []

                _ =
                    values |> Debug.toString |> Debug.log

                pretty =
                    let
                        enc o =
                            Encode.object
                                [ ( "data", Encode.bool o.data )
                                , ( "value", Encode.int o.value )
                                , ( "fields", Encode.list Encode.string o.fields )
                                ]
                    in
                    values
                        |> Encode.list enc
                        |> Encode.encode 2
            in
            simply { model | mText = Just pretty }


type alias MyObject =
    { data : Bool
    , value : Int
    , fields : List String
    }



---- VIEW ----


viewTask : ( TaskId, Household.Task ) -> Element Msg
viewTask ( id, task ) =
    let
        { title, description, status } =
            task
    in
    column
        [ width fill
        , height fill
        , padding 20
        , Background.color (rgb 0.8 0.8 1)
        , Border.rounded 8
        ]
        [ row [ width fill, height fill ]
            [ el [ width fill ] <| text title
            , el
                [ width <| px 80
                , height <| px 80
                , padding 10
                , Font.center
                , Background.color Colors.white
                ]
              <|
                text "IMAGE"
            ]
        , paragraph [ width fill ] [ text description ]
        , row [ spacing 10, padding 10 ]
            [ Input.button [ padding 4, Border.width 1 ]
                { label = text "clear title"
                , onPress = Just <| TaskSetTitle id ""
                }
            , Input.button [ padding 4, Border.width 1 ]
                { label = text "clear description"
                , onPress = Just <| TaskSetDescription id ""
                }
            ]
        , let
            ( color, string ) =
                case status of
                    Household.Todo ->
                        ( Background.color Colors.blue, "Todo" )

                    Household.Done ->
                        ( Background.color Colors.green, "Done" )

                    Household.Disabled ->
                        ( Background.color <| Colors.gray 0.7, "Disabled" )

                    Household.Planned ->
                        ( Background.color Colors.purple, "Planned" )
          in
          Input.button [ color, padding 10, Border.rounded 5 ]
            { label = text string
            , onPress =
                Just <|
                    TaskSetStatus id <|
                        Household.nextStatus status
            }
        ]


layoutSelector : LayoutMode -> Element Msg
layoutSelector layoutMode =
    let
        layoutButton layout =
            if layoutMode == layout then
                none

            else
                Input.button
                    [ padding 4
                    , Background.color Theme.button
                    , width <| px 120
                    ]
                    { label = text <| layoutName layout
                    , onPress = Just <| SetLayoutMode layout
                    }
    in
    row []
        [ text "Layout:"
        , layoutButton Mobile
        , layoutButton Wide
        , layoutButton Centered
        ]


header : Model -> Element Msg
header { layoutMode } =
    row
        [ width fill
        , height (fill |> minimum 40)
        , Background.color Theme.header
        , padding 8
        ]
        [ text "header"
        , layoutSelector layoutMode
        ]


footer : Model -> Element Msg
footer {} =
    row
        [ width fill
        , height (fill |> minimum 40)
        , Background.color Theme.header
        , padding 8
        ]
        [ text "footer" ]


appMain : Model -> Element Msg
appMain { layoutMode, tasks, mText } =
    let
        attrs =
            [ padding 16
            , Background.color Colors.white
            , width fill
            , height fill
            ]
    in
    case layoutMode of
        Wide ->
            column attrs
                [ text "main (wide)"
                , tasks
                    |> Table.pairs
                    |> List.map viewTask
                    |> row []
                ]

        _ ->
            column attrs
                [ text "main (mobile/centered)"
                , mText
                    |> Maybe.map text
                    |> Maybe.withDefault none
                , tasks
                    |> Table.pairs
                    |> List.map viewTask
                    |> column []
                ]


view : Model -> Element Msg
view model =
    let
        app =
            column [ width fill, height fill, Background.color Colors.blue ]
                [ el [ width fill, height fill ] <| header model
                , el [ width fill, height <| minimum 200 <| fillPortion 6 ] <| appMain model
                , el [ width fill, height fill ] <| footer model
                ]
    in
    case model.layoutMode of
        Centered ->
            row [ width fill, height fill ]
                [ el
                    [ width fill
                    , height fill
                    , Background.color Colors.red
                    ]
                    none
                , el
                    [ width <| minimum 400 <| fillPortion 2
                    , height fill
                    ]
                    app
                , el
                    [ width fill
                    , height fill
                    , Background.color Colors.green
                    ]
                    none
                ]

        _ ->
            app



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view =
            view
                >> layout
                    [ width fill
                    , height fill
                    , Background.color Theme.background
                    ]
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
