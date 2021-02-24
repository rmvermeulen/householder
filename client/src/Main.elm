port module Main exposing (..)

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
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Table exposing (..)
import Theme
import User exposing (User)


port windowSize : (Size Int -> msg) -> Sub msg



---- MODEL ----


type Page
    = Home
    | Login
    | Users


pagePath : Page -> String
pagePath page =
    case page of
        Home ->
            "/"

        Login ->
            "/login"

        Users ->
            "/users"


pathPage : String -> Maybe Page
pathPage path =
    case path of
        "/" ->
            Just Home

        "/login" ->
            Just Login

        "/users" ->
            Just Users

        _ ->
            Nothing


type alias Model =
    { tasks : Table Household.Task
    , mText : Maybe String
    , users : List User
    , page : Page
    , size : Size Int
    }


type alias Size t =
    { x : t, y : t }


type alias Flags =
    { path : String
    , size : Size Int
    }


init : Flags -> ( Model, Cmd Msg )
init { path, size } =
    ( { tasks =
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
      , users =
            [ User 0 "Bob" "Alderson" True
            , User 1 "Karen" "Flim" True
            ]
      , page = Maybe.withDefault Home (pathPage path)
      , size = size
      }
    , Cmd.batch
        [ Http.get
            { url = "http://localhost:4000"
            , expect = Http.expectJson ReceiveUsers (Decode.list User.decodeUser)
            }
        ]
    )



---- UPDATE ----


type alias TaskId =
    Table.Id Household.Task


type Msg
    = AddTask Household.Task
    | TaskSetTitle TaskId String
    | TaskSetDescription TaskId String
    | TaskSetStatus TaskId Household.Status
    | ReceiveUsers (Result Http.Error (List User))
    | SetUsers (List User)
    | SetPage Page
    | SetSize (Size Int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        simply m =
            ( m, Cmd.none )
    in
    case msg of
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

        ReceiveUsers (Ok users) ->
            update (SetUsers users) model

        ReceiveUsers (Err error) ->
            simply { model | mText = Just <| Debug.toString error }

        SetUsers users ->
            simply { model | users = users }

        SetPage page ->
            simply { model | page = page }

        SetSize size ->
            simply { model | size = size }



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


header : Model -> Element Msg
header { page, size } =
    column
        [ width fill
        , height (fill |> minimum 40)
        , Background.color Theme.header
        , padding 8
        ]
        [ text <| pagePath page
        , row [ width fill, height fill ]
            [ text "header"
            , text <| Debug.toString size
            ]
        ]


footer : Model -> Element Msg
footer { mText } =
    row
        [ width fill
        , height (fill |> minimum 40)
        , Background.color Theme.header
        , padding 8
        ]
        [ mText
            |> Maybe.map text
            |> Maybe.withDefault none
        ]


appMain : Model -> Element Msg
appMain { tasks, size } =
    let
        attrs =
            [ padding 16
            , Background.color Colors.white
            , width fill
            , height fill
            ]

        sidebar c =
            el [ width fill, height fill, Background.color c ] none
    in
    row attrs
        [ sidebar Colors.red
        , column
            [ width <|
                minimum (min size.x 800) <|
                    maximum 1200 <|
                        fillPortion 8
            ]
            [ tasks
                |> Table.pairs
                |> List.map viewTask
                |> column [ width fill ]
            ]
        , sidebar Colors.green
        ]


view : Model -> Element Msg
view model =
    column [ width fill, height fill, Background.color Colors.blue ]
        [ el [ width fill, height fill ] <| header model
        , el
            [ width fill
            , height <| minimum 200 <| fillPortion 6
            ]
          <|
            appMain model
        , el [ width fill, height fill ] <| footer model
        ]



---- PROGRAM ----


main : Program Flags Model Msg
main =
    Browser.element
        { view =
            view
                >> layout
                    [ width fill
                    , height fill
                    , Background.color Theme.background
                    ]
        , init = init
        , update = update
        , subscriptions =
            \_ ->
                Sub.batch
                    [ windowSize SetSize
                    ]
        }
