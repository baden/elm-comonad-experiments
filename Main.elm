module Main exposing (main)

import Html exposing (Html)
import Pipe exposing (Updater, Lens, lensUpdater)
import Counter1
import Counter2
import Timer
import Delay
import FullStack


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
    , fullstack : FullStack.Model
    }


init : Model
init =
    { counter1 = Counter1.init
    , counter2 = Counter2.init
    , counter2_pcmd = 0
    , timer = Timer.init
    , delay = Delay.init
    , fullstack = FullStack.init
    }


counter1 : Lens Model Counter1.Model
counter1 =
    Lens .counter1 (\v m -> { m | counter1 = v })



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


delay : Lens Model Delay.Model
delay =
    Lens .delay (\v m -> { m | delay = v })


timer : Lens Model Timer.Model
timer =
    Lens .timer (\v m -> { m | timer = v })


fullstackUpdater : Updater FullStack.Model -> Updater Model
fullstackUpdater child_updater =
    \m -> { m | fullstack = child_updater m.fullstack }


parentCmd : Updater Model
parentCmd m =
    { m | counter2_pcmd = m.counter2_pcmd + 1 }



-- view subscriptions


view : Model -> Html (Updater Model)
view model =
    Html.div
        []
        [ Html.text "Counter1:"
        , Pipe.view Counter1.view counter1 model
        , Html.span [] [ Html.text <| toString model.counter2_pcmd ]
        , Counter2.view { doIt = parentCmd } model.counter2
            |> Html.map nestedCounter2Updater
        , Pipe.view Delay.view delay model
        , Pipe.view Timer.view timer model
        , Html.div [] [ Html.text <| "Model: " ++ toString model ]
        , FullStack.view model.fullstack
            |> Html.map fullstackUpdater
        ]


commands : Model -> ( Model, Cmd (Updater Model) )
commands model =
    let
        -- lens =
        --     delay
        ( delay_model, delay_cmds ) =
            Delay.commands model.delay

        -- |> Cmd.map (lensUpdater lens)
        _ =
            Debug.log "pipe1" ( delay_model, delay_cmds )
    in
        ( { model | delay = delay_model }
          -- , Cmd.none
        , Cmd.batch
            [ delay_cmds
                |> Cmd.map
                    (\delay_updater ->
                        \m ->
                            let
                                _ =
                                    Debug.log "subdelay" 0
                            in
                                { m | delay = delay_updater m.delay }
                    )
            ]
        )



-- Cmd.batch
--     [ Pipe.commands Delay.commands delay model
--     ]


subscriptions : Model -> Sub (Updater Model)
subscriptions model =
    Sub.batch
        [ Pipe.subscriptions Timer.subscriptions timer model
        ]
