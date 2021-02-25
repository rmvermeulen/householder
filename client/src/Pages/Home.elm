module Pages.Home exposing (..)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Framework.Button as Button
import Framework.Card as Card
import Framework.Color as Color
import Framework.Modifier exposing (Modifier(..))
import Grid
import Household
import Table exposing (Table)


viewTask taskSetStatus taskSetTitle taskSetDescription ( id, task ) =
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
                    , onPress = Just <| taskSetTitle id ""
                    }
                , Input.button [ padding 4, Border.width 1, Font.color Color.red ]
                    { label = text "clear description"
                    , onPress = Just <| taskSetDescription id ""
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
                        taskSetStatus id <|
                            Household.nextStatus status
                }
            , Button.button
                [ Medium
                , Success
                , Outlined
                ]
                Nothing
                "Button"
            ]


view taskSetStatus taskSetTitle taskSetDescription attrs { size, tasks } =
    row attrs
        [ tasks
            |> Table.pairs
            |> List.map (viewTask taskSetStatus taskSetTitle taskSetDescription)
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
