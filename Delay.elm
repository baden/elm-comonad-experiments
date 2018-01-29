module Delay exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)
import Process
import Task
import Time exposing (Time, millisecond)
import Pipe exposing (Updater)


type Model
    = Value Int
    | CommandDelay


init : Model
init =
    Value 0


after : Time -> msg -> Cmd msg
after time msg =
    Process.sleep time
        |> Task.perform (always msg)


commands : Model -> Cmd (Updater Model)
commands model =
    case model of
        CommandDelay ->
            after 3000 (always <| Value 2)

        Value _ ->
            Cmd.none


view : Model -> Html (Updater Model)
view model =
    let
        disabled_key =
            case model of
                CommandDelay ->
                    True

                _ ->
                    False
    in
        div []
            [ button
                [ onClick (always CommandDelay)
                , disabled disabled_key
                ]
                [ text "Press me for delayed command" ]
            , span [] [ text <| toString model ]
            ]
