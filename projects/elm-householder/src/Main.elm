module Main exposing (..)

import Browser
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Theme



---- MODEL ----


type LayoutMode
    = Mobile
    | Wide
    | Compact


type alias Model =
    { layoutMode : LayoutMode
    }


init : ( Model, Cmd Msg )
init =
    ( Model Compact, Cmd.none )



---- UPDATE ----


type Msg
    = SetLayoutMode LayoutMode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetLayoutMode mode ->
            ( { model | layoutMode = mode }, Cmd.none )



---- VIEW ----


header {} =
    row
        [ width fill
        , height <| px 80
        , Background.color Theme.header
        , padding 8
        ]
        [ text "header"
        ]


footer {} =
    row [] [ text "footer" ]


appMain { layoutMode } =
    case layoutMode of
        Mobile ->
            column [ padding 16 ] [ text "main (mobile)" ]

        Wide ->
            column [ padding 16 ] [ text "main (wide)" ]

        Compact ->
            column [ padding 16 ] [ text "main (compact)" ]


view : Model -> Element Msg
view model =
    column [ width fill ]
        [ header model
        , appMain model
        , footer model
        ]



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
