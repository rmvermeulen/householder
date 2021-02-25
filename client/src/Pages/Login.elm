module Pages.Login exposing (..)

import Binary
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Framework.Button as Button
import Framework.Card as Card
import Framework.Color as Color
import Framework.FormField as FormField
import Framework.Modifier as Modifier
import Grid
import SHA
import Table
import User exposing (HashedPassword(..), User)


type alias Model =
    { username : String
    , password : String
    , visible : Bool
    , mFocusedField : Maybe FormField.Field
    }


type Msg
    = SetFocus FormField.Field
    | RemoveFocus FormField.Field
    | SetInput FormField.Field String
    | ToggleVisibility FormField.Field


init : Model
init =
    Model "" "" False Nothing


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    let
        simply m =
            ( m, Cmd.none )
    in
    case msg of
        SetFocus field ->
            simply { model | mFocusedField = Just field }

        RemoveFocus field ->
            simply
                { model | mFocusedField = Maybe.map (always field) model.mFocusedField }

        SetInput field input ->
            case field of
                FormField.FieldUsername ->
                    simply { model | username = input }

                FormField.FieldCurrentPassword ->
                    simply { model | password = input }

                _ ->
                    simply model

        ToggleVisibility field ->
            if field == FormField.FieldCurrentPassword then
                simply { model | visible = not model.visible }

            else
                simply model


viewUsername : Maybe FormField.Field -> String -> Element Msg
viewUsername mFocusedField username =
    FormField.inputText []
        { field = FormField.FieldUsername
        , fieldValue = username
        , helperText = Nothing
        , inputType = Input.text
        , inputTypeAttrs = []
        , label = el [ Font.italic ] <| text "username"
        , maybeFieldFocused = mFocusedField
        , maybeMsgOnEnter = Nothing
        , msgOnChange = SetInput
        , msgOnFocus = SetFocus
        , msgOnLoseFocus = RemoveFocus
        }


viewPassword : Maybe FormField.Field -> Bool -> String -> Element Msg
viewPassword mFocusedField visible password =
    FormField.inputPassword []
        { field = FormField.FieldCurrentPassword
        , fieldValue = password
        , helperText = Nothing
        , inputType = Input.currentPassword
        , inputTypeAttrs = []
        , label = el [ Font.italic ] <| text "password"
        , maybeFieldFocused = mFocusedField
        , maybeMsgOnEnter = Nothing
        , maybeShowHidePassword =
            let
                tb t =
                    Input.button []
                        { label = text t, onPress = Nothing }

                hide =
                    tb "hide"

                show =
                    tb "show"
            in
            Just <|
                { maybeHideIcon =
                    Just hide
                , maybeShowIcon =
                    Just show
                , msgOnViewToggle = ToggleVisibility
                }
        , msgOnChange = SetInput
        , msgOnFocus = SetFocus
        , msgOnLoseFocus = RemoveFocus
        , show = visible
        }


view : (User -> msg) -> (Element Msg -> Element msg) -> Model -> Element msg
view createUser remap { username, password, visible, mFocusedField } =
    Card.simpleWithTitle "Login" "" <|
        let
            user : User
            user =
                { id = 0
                , firstName = ""
                , lastName = ""
                , username = username
                , passwordHash =
                    Hex
                        (password
                            |> Binary.fromStringAsUtf8
                            |> SHA.sha256
                            |> Binary.toHex
                        )
                , isActive = True
                }
        in
        column
            [ width fill, height fill ]
            [ remap (username |> viewUsername mFocusedField)
            , remap (password |> viewPassword mFocusedField visible)
            , Button.button [ Modifier.Primary ] (Just <| createUser user) "Submit"
            ]
