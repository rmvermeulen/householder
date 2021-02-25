port module Main exposing (..)

import Binary
import Browser
import Debug
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
import Pages.Home as Home
import Pages.Login as Login
import Pages.Users as Users
import SHA
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
    { tasks : Table Household.Task
    , mText : Maybe String
    , users : List User
    , mUser : Maybe User
    , page : Page
    , size : Size Int
    , login : Login.Model
    }


type alias Size t =
    { x : t, y : t }


type alias Flags =
    { path : String
    , size : Size Int
    }


hashPassword : String -> HashedPassword
hashPassword =
    Binary.fromStringAsUtf8
        >> SHA.sha256
        >> Binary.toHex
        >> Hex


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
                    |> Table.fromList
            , mText = Nothing
            , users =
                [ User 0 "Bob" "Alderson" "bob03" (hashPassword "abcd") True
                , User 1 "Karen" "Flim" "kf" (hashPassword "abcd") True
                ]
            , mUser = Nothing
            , page = Login
            , size = size
            , login = Login.init
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
    Table.Id Household.Task


type Msg
    = NoOp
    | LoginMsg Login.Msg
    | LoginUser Login.LoginData
    | AddTask Household.Task
    | TaskSetTitle TaskId String
    | TaskSetDescription TaskId String
    | TaskSetStatus TaskId Household.Status
    | ReceiveUsers (Result Http.Error (List User))
    | SetUsers (List User)
    | SetPage Page
    | SetSize (Size Int)


find : (item -> Bool) -> List item -> Maybe item
find pred =
    List.filter pred >> List.head


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
                    Login.update loginMsg model.login
            in
            ( { model | login = login }, Cmd.map LoginMsg cmd )

        LoginUser { username, passwordHash } ->
            let
                mUser =
                    find (.username >> (==) username) model.users

                result : Maybe Login.Error
                result =
                    case mUser of
                        Just user ->
                            if user.passwordHash == passwordHash then
                                Nothing

                            else
                                Just Login.WrongPassword

                        Nothing ->
                            Just Login.UnknownUsername
            in
            case result of
                Nothing ->
                    let
                        user : User
                        user =
                            let
                                n =
                                    1 + List.length model.users
                            in
                            { id = n * n
                            , firstName = ""
                            , lastName = ""
                            , username = username
                            , passwordHash = passwordHash
                            , isActive = True
                            }
                    in
                    update (SetPage Home) { model | mUser = Just user }

                Just error ->
                    let
                        ( login, cmd ) =
                            Just error
                                |> Login.SetError
                                |> (\m -> Login.update m model.login)
                    in
                    ( { model | login = login }, Cmd.map LoginMsg cmd )

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



---- VIEW ----


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
appMain { login, page, users, tasks, size } =
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
            Home.view TaskSetStatus
                TaskSetTitle
                TaskSetDescription
                attrs
                { size = size
                , tasks = tasks
                }

        Login ->
            login
                |> Login.view LoginUser (Element.map LoginMsg)
                |> el [ width shrink, height fill, padding 80 ]

        Users ->
            Users.view
                { users = users
                }


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
