module Delay exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)
import Process
import Task
import Time exposing (Time, millisecond)
import Pipe exposing (Updater, Pipe, pure, Worker, modify, modify_and_cmd)


type State
    = Init
    | Started
    | Done


type alias Model =
    { state : State
    , value : Int
    }


init : Pipe Model
init =
    pure (Model Init 0)


after : Time -> msg -> Cmd msg
after time msg =
    Process.sleep time
        |> Task.perform (always msg)


startDelay : Worker Model
startDelay =
    modify_and_cmd
        (\m -> { m | state = Started })
        (after 3000 endDelay)


endDelay : Worker Model
endDelay =
    modify (\m -> { m | state = Done })


view : Model -> Html (Worker Model)
view model =
    div []
        [ button
            [ onClick startDelay
            , disabled (model.state == Started)
            ]
            [ text "Press me for delayed command" ]
        , span [] [ text <| toString model ]
        ]
