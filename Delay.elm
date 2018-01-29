module Delay exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Process
import Task
import Time exposing (Time, millisecond)


type alias Model =
    Int


init : Model
init =
    0


after : Time -> msg -> Cmd msg
after time msg =
    Process.sleep time
        |> Task.perform (always msg)


commands : Model -> Cmd (Model -> Model)
commands model =
    case model of
        1 ->
            after 3000 (always 2)

        _ ->
            Cmd.none


view : Model -> Html (Model -> Model)
view model =
    div []
        [ button [ onClick (always 1) ] [ text "Press me for delayed command" ]
        , span [] [ text <| toString model ]
        ]
