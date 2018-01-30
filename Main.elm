module Main exposing (main)

import Html exposing (Html)
import Pipe
    exposing
        ( Updater
        , Lens
        , lensUpdater
        , map
        , Pipe
        , pure
        , full
        , Worker
        , modify
        , modify_and_cmd
        , WorkerCmds
        )
import Counter1
import Delay
import Process
import Task
import Time exposing (Time, millisecond)
import Timer


-- import Counter2
-- import FullStack


main : Program Never Model (Worker Model)
main =
    Pipe.program
        { init = init
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { counter1 : Counter1.Model

    -- , counter2 : Counter2.Model
    -- , counter2_pcmd : Int
    , timer : Timer.Model
    , delay : Delay.Model

    -- , fullstack : FullStack.Model
    }


after : Time -> msg -> Cmd msg
after time msg =
    Process.sleep time
        |> Task.perform (always msg)


init : Pipe Model
init =
    let
        ( delay_model, delay_cmd ) =
            Debug.log "Delay.init" Delay.init
    in
        full
            { counter1 = Tuple.first Counter1.init

            -- , counter2 = Tuple.first Counter2.init
            -- , counter2_pcmd = 0
            , timer = Tuple.first Timer.init
            , delay = delay_model

            -- , fullstack = Tuple.first FullStack.init
            }
            -- Cmd.none
            (Cmd.batch
                [ (after 3000 endDelay)
                , delay_cmd |> Pipe.map delay
                ]
            )


endDelay : Worker Model
endDelay =
    modify_and_cmd
        (\m ->
            let
                _ =
                    Debug.log "Main end delay 1" m
            in
                m
        )
        (after 3000 endDelay2)


endDelay2 : Worker Model
endDelay2 =
    modify
        (\m ->
            let
                _ =
                    Debug.log "Main end delay2" m
            in
                m
        )



-- , WorkerCmds Cmd.none
-- )


counter1 : Lens Model Counter1.Model
counter1 =
    Lens .counter1 (\v m -> { m | counter1 = v })



-- TODO: Цей зразок тільки як приклад. У реальному житті, можливо треба вертати
-- якось більш розумно
-- Тут не використовується cm_updater якщо є pcmd
-- nestedCounter2Updater :
-- nestedCounter2Updater :
--     ( Maybe (Updater Model), Updater Counter2.Model )
--     -> Updater Model
-- nestedCounter2Updater ( pcmd, cm_updater ) =
--     let
--         updater m =
--             { m | counter2 = cm_updater m.counter2 }
--     in
--         case pcmd of
--             Nothing ->
--                 updater
--
--             Just parent_updater ->
--                 parent_updater << updater
--
--


delay : Lens Model Delay.Model
delay =
    Lens .delay (\v m -> { m | delay = v })



--
--


timer : Lens Model Timer.Model
timer =
    Lens .timer (\v m -> { m | timer = v })



--
--
-- fullstackUpdater : Updater FullStack.Model -> Updater Model
-- fullstackUpdater child_updater =
--     \m -> { m | fullstack = child_updater m.fullstack }
--
--
-- parentCmd : Updater Model
-- parentCmd m =
--     { m | counter2_pcmd = m.counter2_pcmd + 1 }
-- view subscriptions


view : Model -> Html (Worker Model)
view model =
    Html.div
        []
        [ Html.text "Counter1:"
        , Pipe.view Counter1.view counter1 model

        -- , Html.span [] [ Html.text <| toString model.counter2_pcmd ]
        -- , Counter2.view { doIt = parentCmd } model.counter2
        --     |> Html.map nestedCounter2Updater
        , Pipe.view Delay.view delay model
        , Pipe.view Timer.view timer model

        -- , FullStack.view model.fullstack
        --     |> Html.map fullstackUpdater
        , Html.div [] [ Html.text <| "Model: " ++ toString model ]
        ]


subscriptions : Model -> Sub (Worker Model)
subscriptions model =
    -- Sub.none
    Sub.batch
        [ Pipe.subscriptions Timer.subscriptions timer model
        ]
