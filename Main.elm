module Main exposing (main)

import Html exposing (Html)


-- import Html.Events

import Counter1
import Counter2
import Timer
import Delay


type alias Program model =
    { commands : model -> Cmd (model -> model)
    , model : model
    , subscriptions : model -> Sub (model -> model)
    , view : model -> Html (model -> model)
    }


{-| Create a program from an alternative program.
-}
program : Program model -> Platform.Program Never model (model -> model)
program { commands, model, subscriptions, view } =
    Html.program
        { init = ( model, commands model )
        , subscriptions = subscriptions
        , update =
            \updater model ->
                let
                    new_model =
                        updater model
                in
                    ( new_model, commands new_model )
        , view = view
        }



-- update1 : m -> a -> ( m, Cmd m )
-- Application


main : Platform.Program Never Model (Model -> Model)
main =
    program
        { commands = commands
        , model = init
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { counter1 : Counter1.Model
    , counter2 : Counter2.Model
    , timer : Timer.Model
    , delay : Delay.Model
    }


commands : Model -> Cmd (Model -> Model)
commands model =
    let
        _ =
            Debug.log "commands" model
    in
        Cmd.batch
            [ Delay.commands model.delay |> Cmd.map delayUpdater
            ]


init : Model
init =
    { counter1 = Counter1.init
    , counter2 = Counter2.init
    , timer = Timer.init
    , delay = Delay.init
    }


counter1Updater : (Counter1.Model -> Counter1.Model) -> Model -> Model
counter1Updater counter1_updater =
    \m -> { m | counter1 = counter1_updater m.counter1 }


counter2Updater : (Counter2.Model -> Counter2.Model) -> Model -> Model
counter2Updater counter2_updater =
    \m -> { m | counter2 = counter2_updater m.counter2 }


delayUpdater : (Delay.Model -> Delay.Model) -> Model -> Model
delayUpdater dm_updater =
    \m -> { m | delay = dm_updater m.delay }


timerUpdater : (Timer.Model -> Timer.Model) -> Model -> Model
timerUpdater timer_updater =
    \m -> { m | timer = timer_updater m.timer }


view : Model -> Html (Model -> Model)
view model =
    Html.div
        []
        [ Html.text "Counter1:"
        , Counter1.view model.counter1
            |> Html.map counter1Updater
        , Counter2.view
            { doIt = \m -> { m | counter2 = Counter2.init }
            }
            model.counter2
            |> Html.map
                (\( pcmd, cm_updater ) ->
                    Maybe.withDefault
                        (\m -> { m | counter2 = cm_updater m.counter2 })
                        pcmd
                )
        , Delay.view model.delay
            |> Html.map delayUpdater
        , Html.div [] [ Html.text <| "Model: " ++ toString model ]
        ]


subscriptions : Model -> Sub (Model -> Model)
subscriptions model =
    Sub.batch
        [ Timer.subscriptions model.timer |> Sub.map timerUpdater
        ]
