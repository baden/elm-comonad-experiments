module Delay exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)
import Process
import Task
import Time exposing (Time, millisecond)
import Pipe exposing (Updater, Pipe, full, Worker, modify, modify_and_cmd)


type State
    = Init
    | Started
    | Done


type alias Model =
    { state1 : State
    , state2 : State
    , value1 : Int
    , value2 : Int
    }


init : Pipe Model
init =
    full
        (Model Init Started 0 0)
        (after 3000 endDelay2)


after : Time -> msg -> Cmd msg
after time msg =
    Process.sleep time
        |> Task.perform (always msg)


startDelay1 : Worker Model
startDelay1 =
    modify_and_cmd
        (\m -> { m | state1 = Started })
        (after 3000 endDelay1)


endDelay1 : Worker Model
endDelay1 =
    modify (\m -> { m | state1 = Done, value1 = m.value1 + 1 })


endDelay2 : Worker Model
endDelay2 =
    modify (\m -> { m | state2 = Done, value2 = m.value2 + 1 })


view : Model -> Html (Worker Model)
view model =
    div []
        [ button
            [ onClick startDelay1
            , disabled (model.state1 == Started)
            ]
            [ text "Press me for delayed command" ]
        , span [] [ text <| toString model ]
        ]
