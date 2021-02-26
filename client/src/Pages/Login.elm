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


type alias Login =
    { username : String
    , password : String
    , visible : Bool
    , mFocusedField : Maybe FormField.Field
    , mError : Maybe Error
    }


type Error
    = UnknownUsername
    | WrongPassword


type Msg
    = SetFocus FormField.Field
    | RemoveFocus FormField.Field
    | SetInput FormField.Field String
    | ToggleVisibility FormField.Field
    | SetError (Maybe Error)


init : Login
init =
    Login "" "" False Nothing Nothing


update : Msg -> Login -> ( Login, Cmd msg )
update msg login =
    let
        simply m =
            ( m, Cmd.none )
    in
    case msg of
        SetFocus field ->
            simply { login | mFocusedField = Just field }

        RemoveFocus field ->
            simply
                { login | mFocusedField = Maybe.map (always field) login.mFocusedField }

        SetInput field input ->
            case field of
                FormField.FieldUsername ->
                    simply { login | username = input }

                FormField.FieldCurrentPassword ->
                    simply { login | password = input }

                _ ->
                    simply login

        ToggleVisibility field ->
            if field == FormField.FieldCurrentPassword then
                simply { login | visible = not login.visible }

            else
                simply login

        SetError mError ->
            simply { login | mError = mError }


viewUsername : Maybe String -> Maybe FormField.Field -> String -> Element Msg
viewUsername mError mFocusedField username =
    FormField.inputText []
        { field = FormField.FieldUsername
        , fieldValue = username
        , helperText =
            mError
                |> Maybe.map text
        , inputType = Input.text
        , inputTypeAttrs = []
        , label = el [ Font.italic ] <| text "username"
        , maybeFieldFocused = mFocusedField
        , maybeMsgOnEnter = Nothing
        , msgOnChange = SetInput
        , msgOnFocus = SetFocus
        , msgOnLoseFocus = RemoveFocus
        }


viewPassword : Maybe String -> Maybe FormField.Field -> Bool -> String -> Element Msg
viewPassword mError mFocusedField visible password =
    FormField.inputPassword []
        { field = FormField.FieldCurrentPassword
        , fieldValue = password
        , helperText =
            mError
                |> Maybe.map text
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


type alias LoginData =
    { username : String
    , passwordHash : HashedPassword
    }


view : (LoginData -> msg) -> (Element Msg -> Element msg) -> Login -> Element msg
view createUser remap { username, password, visible, mFocusedField, mError } =
    Card.simpleWithTitle "Login" "" <|
        let
            user =
                { username = username
                , passwordHash =
                    Hex
                        (password
                            |> Binary.fromStringAsUtf8
                            |> SHA.sha256
                            |> Binary.toHex
                        )
                }

            fields =
                let
                    mUsernameError =
                        case mError of
                            Just UnknownUsername ->
                                Just "Unknown username!"

                            _ ->
                                Nothing

                    mPasswordError =
                        case mError of
                            Just WrongPassword ->
                                Just "Wrong password!"

                            _ ->
                                Nothing
                in
                [ username |> viewUsername mUsernameError mFocusedField
                , password |> viewPassword mPasswordError mFocusedField visible
                ]
                    |> List.map remap

            controls =
                [ Button.button [ Modifier.Primary ] (Just <| createUser user) "Submit"
                ]
        in
        (fields ++ controls)
            |> column [ width fill, height fill ]
