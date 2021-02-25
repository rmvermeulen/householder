port module Main exposing (..)

import Browser
import Debug
import Dropdown
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Framework.Button as Button
import Framework.Card as Card
import Framework.Color as Color
import Framework.FormField as FormField
import Framework.Modifier exposing (Modifier(..))
import Grid
import Household
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Pages.Login
import Table exposing (..)
import Theme
import User exposing (HashedPassword(..), User)
import Widget


port windowSize : (Size Int -> msg) -> Sub msg


port pathChanged : String -> Cmd msg



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
    { tasks : Table ( Household.Task, Dropdown.State Household.Status )
    , mText : Maybe String
    , users : List User
    , mUser : Maybe User
    , page : Page
    , size : Size Int
    , dropdownState : Dropdown.State Household.Status
    , login : Pages.Login.Model
    }


type alias Size t =
    { x : t, y : t }


type alias Flags =
    { path : String
    , size : Size Int
    }


init : Flags -> ( Model, Cmd Msg )
init { path, size } =
    let
        ( model, cmd ) =
            { tasks =
                [ Household.createTask
                    "Some task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Another task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Some task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Another task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Some task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Another task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Some task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Another task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Some task"
                    "This is just for testing. Don't worry about it."
                , Household.createTask
                    "Another task"
                    "This is just for testing. Don't worry about it."
                ]
                    |> List.map (\task -> ( task, Dropdown.init "status" ))
                    |> Table.fromList
            , mText = Nothing
            , users =
                [ User 0 "Bob" "Alderson" "" (Hex "") True
                , User 1 "Karen" "Flim" "" (Hex "") True
                ]
            , mUser = Nothing
            , page = Login
            , size = size
            , dropdownState = Dropdown.init "status"
            , login = Pages.Login.init
            }
                |> update (SetPage <| Maybe.withDefault Home (pathPage path))
    in
    ( model
    , Cmd.batch
        [ cmd
        , Http.get
            { url = "http://localhost:4000"
            , expect = Http.expectJson ReceiveUsers (Decode.list User.decodeUser)
            }
        ]
    )



---- UPDATE ----


type alias TaskId =
    Table.Id ( Household.Task, Dropdown.State Household.Status )


type Msg
    = NoOp
    | LoginMsg Pages.Login.Msg
    | LoginUser User
    | AddTask Household.Task
    | TaskSetTitle TaskId String
    | TaskSetDescription TaskId String
    | TaskSetStatus TaskId Household.Status
    | ReceiveUsers (Result Http.Error (List User))
    | SetUsers (List User)
    | SetPage Page
    | SetSize (Size Int)
    | DropdownMsg TaskId (Dropdown.Msg Household.Status)
    | DropdownPicked TaskId (Maybe Household.Status)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        simply m =
            ( m, Cmd.none )
    in
    case msg of
        NoOp ->
            simply model

        LoginMsg loginMsg ->
            let
                ( login, cmd ) =
                    Pages.Login.update loginMsg model.login
            in
            ( { model | login = login }, Cmd.map LoginMsg cmd )

        LoginUser user ->
            simply { model | mUser = Just user }

        AddTask task ->
            simply { model | tasks = Table.add ( task, Dropdown.init "status" ) model.tasks |> Tuple.second }

        TaskSetTitle id title ->
            let
                tasks =
                    Table.mapSingle id (Tuple.mapFirst (\task -> { task | title = title })) model.tasks
            in
            simply { model | tasks = tasks }

        TaskSetDescription id description ->
            let
                tasks =
                    Table.mapSingle id (Tuple.mapFirst (\task -> { task | description = description })) model.tasks
            in
            simply { model | tasks = tasks }

        TaskSetStatus id status ->
            let
                tasks =
                    Table.mapSingle id (Tuple.mapFirst (\task -> { task | status = status })) model.tasks
            in
            simply { model | tasks = tasks }

        ReceiveUsers (Ok users) ->
            update (SetUsers users) model

        ReceiveUsers (Err error) ->
            simply { model | mText = Just <| Debug.toString error }

        SetUsers users ->
            simply { model | users = users }

        SetPage page ->
            let
                setPage p =
                    ( { model | page = p }, pathChanged <| pagePath p )
            in
            case model.mUser of
                Just _ ->
                    setPage page

                Nothing ->
                    setPage Login

        SetSize size ->
            simply { model | size = size }

        DropdownMsg tid ddMsg ->
            let
                tasks =
                    Table.mapSingle tid
                        (Tuple.mapSecond
                            (\state ->
                                let
                                    foo : ( Dropdown.State Household.Status, Cmd Msg )
                                    foo =
                                        Dropdown.update (dropdownConfig tid) ddMsg state taskOptionsList

                                    ( s, c ) =
                                        foo
                                in
                                s
                            )
                        )
                        model.tasks
            in
            simply { model | tasks = tasks }

        DropdownPicked tid mString ->
            case mString of
                Just string ->
                    let
                        tasks : Table ( Household.Task, Dropdown.State Household.Status )
                        tasks =
                            let
                                updateTask : ( Household.Task, Dropdown.State Household.Status ) -> ( Household.Task, Dropdown.State Household.Status )
                                updateTask =
                                    Tuple.mapFirst (\task -> { task | status = string })
                            in
                            Table.mapSingle tid updateTask model.tasks
                    in
                    simply { model | tasks = tasks }

                Nothing ->
                    simply model



---- VIEW ----


viewTask : ( TaskId, ( Household.Task, Dropdown.State Household.Status ) ) -> Element Msg
viewTask ( id, ( task, state ) ) =
    let
        { title, description, status } =
            task
    in
    Card.simpleWithTitle "Task" title <|
        column
            [ width fill
            , height fill
            ]
            [ row [ width fill, height fill ]
                [ paragraph [ width fill ] [ text description ]
                , el
                    [ width <| px 80
                    , height <| px 80
                    , padding 10
                    , Font.center
                    , Background.color Color.green
                    ]
                  <|
                    text "IMAGE"
                ]
            , row [ spacing 10, padding 10 ]
                [ Input.button [ padding 4, Border.width 1, Font.color Color.red ]
                    { label = text "clear title"
                    , onPress = Just <| TaskSetTitle id ""
                    }
                , Input.button [ padding 4, Border.width 1, Font.color Color.red ]
                    { label = text "clear description"
                    , onPress = Just <| TaskSetDescription id ""
                    }
                ]
            , let
                ( color, string ) =
                    case status of
                        Household.Todo ->
                            ( Background.color Color.blue, "Todo" )

                        Household.Done ->
                            ( Background.color Color.green, "Done" )

                        Household.Disabled ->
                            ( Background.color <| Color.red, "Disabled" )

                        Household.Planned ->
                            ( Background.color Color.purple, "Planned" )
              in
              Input.button [ color, padding 10, Border.rounded 5 ]
                { label = text string
                , onPress =
                    Just <|
                        TaskSetStatus id <|
                            Household.nextStatus status
                }
            , Dropdown.view (dropdownConfig id)
                state
                taskOptionsList
            , Button.button
                [ Medium
                , Success
                , Outlined
                ]
                Nothing
                "Button"
            ]


header : Model -> Element Msg
header { page, size } =
    column
        [ width fill
        , fill |> minimum 40 |> height
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
        , fill |> minimum 40 |> height
        , Background.color Theme.header
        , padding 8
        ]
        [ mText
            |> Maybe.map text
            |> Maybe.withDefault none
        ]


appMain : Model -> Element Msg
appMain { login, page, tasks, size } =
    let
        attrs =
            [ padding 16
            , Background.color Color.white
            , width fill
            , height fill
            ]
    in
    case page of
        Home ->
            row attrs
                [ tasks
                    |> Table.pairs
                    |> List.map viewTask
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

        Login ->
            login
                |> Pages.Login.view LoginUser (Element.map LoginMsg)
                |> el [ width shrink, height fill, padding 80 ]

        Users ->
            text "users overview (TODO)"


view : Model -> Element Msg
view model =
    column [ width fill, height fill, Background.color Color.blue ]
        [ el [ width fill, height fill ] <| header model
        , el
            [ width fill
            , fillPortion 6
                |> minimum 200
                |> height
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



---- config


dropdownConfig : TaskId -> Dropdown.Config Household.Status Msg
dropdownConfig tid =
    let
        itemToPrompt item =
            text <| Debug.toString item

        itemToElement selected highlighted item =
            text <| Debug.toString item
    in
    Dropdown.basic (DropdownMsg tid) (DropdownPicked tid) itemToPrompt itemToElement


taskOptionsList : List Household.Status
taskOptionsList =
    [ Household.Todo
    , Household.Done
    , Household.Disabled
    , Household.Planned
    ]
