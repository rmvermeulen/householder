module Chore exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Framework.Button as Button
import Framework.Card as Card
import Framework.Color as Color
import Framework.Modifier exposing (Modifier(..))
import Time


type Status
    = Todo
    | Done
    | Disabled
    | Planned


nextStatus : Status -> Status
nextStatus status =
    case status of
        Todo ->
            Done

        Done ->
            Disabled

        Disabled ->
            Planned

        Planned ->
            Todo


type alias Id =
    Int


type alias Chore =
    { id : Id
    , title : String
    , description : String
    , blocks : List Id
    , expanded : Bool
    , deadline : Maybe Time.Posix
    , status : Status
    }


quick : Id -> String -> String -> Chore
quick id title description =
    Chore id title description [] False Nothing Todo


type Msg
    = SetTitle String
    | SetDescription String
    | SetBlockList (List Id)
    | SetExpanded Bool
    | SetStatus Status


update : Msg -> Chore -> ( Chore, Cmd Msg )
update msg model =
    let
        simply m =
            ( m, Cmd.none )
    in
    case msg of
        SetTitle title ->
            simply { model | title = title }

        SetDescription description ->
            simply { model | description = description }

        SetBlockList blocks ->
            simply { model | blocks = blocks }

        SetExpanded expanded ->
            simply { model | expanded = expanded }

        SetStatus status ->
            simply { model | status = status }


view : Chore -> Element Msg
view { title, description, status, expanded } =
    if expanded then
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
                        , onPress = Just <| SetTitle ""
                        }
                    , Input.button [ padding 4, Border.width 1, Font.color Color.red ]
                        { label = text "clear description"
                        , onPress = Just <| SetDescription ""
                        }
                    ]
                , let
                    ( color, string ) =
                        case status of
                            Todo ->
                                ( Background.color Color.blue, "Todo" )

                            Done ->
                                ( Background.color Color.green, "Done" )

                            Disabled ->
                                ( Background.color <| Color.red, "Disabled" )

                            Planned ->
                                ( Background.color Color.purple, "Planned" )
                  in
                  Input.button [ color, padding 10, Border.rounded 5 ]
                    { label = text string
                    , onPress = Just <| SetStatus (nextStatus status)
                    }
                , Button.button
                    [ Medium
                    , Success
                    , Outlined
                    ]
                    Nothing
                    "Button"
                ]

    else
        Card.simple <|
            Button.button [] (Just <| SetExpanded <| not expanded) title
