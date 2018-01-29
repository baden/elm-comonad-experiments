module Main exposing (main)

import Html exposing (Html)
import Pipe exposing (Updater)
import Counter1
import Counter2
import Timer
import Delay


main : Program Never Model (Updater Model)
main =
    Pipe.program
        { commands = commands
        , model = init
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { counter1 : Counter1.Model
    , counter2 : Counter2.Model
    , counter2_pcmd : Int
    , timer : Timer.Model
    , delay : Delay.Model
    }


commands : Model -> Cmd (Updater Model)
commands model =
    -- let
    --     _ =
    --         Debug.log "commands" model
    -- in
    Cmd.batch
        [ Delay.commands model.delay |> Cmd.map delayUpdater
        ]


init : Model
init =
    { counter1 = Counter1.init
    , counter2 = Counter2.init
    , counter2_pcmd = 0
    , timer = Timer.init
    , delay = Delay.init
    }


counter1Updater : Updater Counter1.Model -> Updater Model
counter1Updater counter1_updater =
    \m -> { m | counter1 = counter1_updater m.counter1 }


counter2Updater : Updater Counter2.Model -> Updater Model
counter2Updater counter2_updater =
    \m -> { m | counter2 = counter2_updater m.counter2 }



-- TODO: Цей зразок тільки як приклад. У реальному житті, можливо треба вертати
-- якось більш розумно
-- Тут не використовується cm_updater якщо є pcmd
-- nestedCounter2Updater :


nestedCounter2Updater :
    ( Maybe (Updater Model), Updater Counter2.Model )
    -> Updater Model
nestedCounter2Updater ( pcmd, cm_updater ) =
    let
        updater m =
            { m | counter2 = cm_updater m.counter2 }
    in
        case pcmd of
            Nothing ->
                updater

            Just parent_updater ->
                parent_updater << updater


delayUpdater : Updater Delay.Model -> Updater Model
delayUpdater dm_updater =
    \m -> { m | delay = dm_updater m.delay }


timerUpdater : Updater Timer.Model -> Updater Model
timerUpdater timer_updater =
    \m -> { m | timer = timer_updater m.timer }


parentCmd : Updater Model
parentCmd m =
    { m | counter2_pcmd = m.counter2_pcmd + 1 }


view : Model -> Html (Updater Model)
view model =
    Html.div
        []
        [ Html.text "Counter1:"
        , Counter1.view model.counter1
            |> Html.map counter1Updater
        , Html.span [] [ Html.text <| toString model.counter2_pcmd ]
        , Counter2.view { doIt = parentCmd } model.counter2
            |> Html.map nestedCounter2Updater
        , Delay.view model.delay
            |> Html.map delayUpdater
        , Timer.view model.timer
            |> Html.map timerUpdater
        , Html.div [] [ Html.text <| "Model: " ++ toString model ]
        ]


subscriptions : Model -> Sub (Updater Model)
subscriptions model =
    Sub.batch
        [ Timer.subscriptions model.timer |> Sub.map timerUpdater
        ]
