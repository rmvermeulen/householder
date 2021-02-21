module Main exposing (..)

import Browser
import Colors
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
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
    }


init : ( Model, Cmd Msg )
init =
    ( Model Centered, Cmd.none )



---- UPDATE ----


type Msg
    = SetLayoutMode LayoutMode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetLayoutMode mode ->
            ( { model | layoutMode = mode }, Cmd.none )



---- VIEW ----


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
appMain { layoutMode } =
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
                , row [] []
                ]

        _ ->
            column attrs [ text "main (mobile/centered)" ]


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
