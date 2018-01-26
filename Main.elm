module Main exposing (main)

import Html exposing (Html)


-- import Html.Events

import Counter1
import Counter2
import Timer
import Delay


type alias Program model =
    { commands : model -> Cmd model
    , model : model
    , subscriptions : model -> Sub model
    , view : model -> Html model
    }


{-| Create a program from an alternative program.
-}
program : Program model -> Platform.Program Never model model
program { commands, model, subscriptions, view } =
    Html.program
        { init = ( model, commands model )
        , subscriptions = subscriptions
        , update = \model _ -> ( model, commands model )
        , view = view
        }



-- update1 : m -> a -> ( m, Cmd m )
-- Application


main : Platform.Program Never Model Model
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


commands : Model -> Cmd Model
commands model =
    let
        _ =
            Debug.log "commands" model
    in
        Cmd.batch
            [ Delay.commands model.delay |> Cmd.map (\dm -> { model | delay = dm })
            ]


init : Model
init =
    { counter1 = Counter1.init
    , counter2 = Counter2.init
    , timer = Timer.init
    , delay = Delay.init
    }


setCounter1Model : Counter1.Model -> Model -> Model
setCounter1Model cm model =
    { model | counter1 = cm }


setCounter2Model : Counter2.Model -> Model -> Model
setCounter2Model cm model =
    { model | counter2 = cm }


setTimerModel : Timer.Model -> Model -> Model
setTimerModel tm model =
    { model | timer = tm }


view : Model -> Html Model
view model =
    Html.div
        []
        [ Html.text "Counter1:"
        , Counter1.view model.counter1
            |> Html.map (flip setCounter1Model model)
        , Counter2.view { doIt = (setCounter2Model Counter2.init model) } model.counter2
            |> Html.map
                (\( pcmd, cm ) ->
                    Maybe.withDefault (setCounter2Model cm model) pcmd
                )
        , Delay.view model.delay |> Html.map (\dm -> { model | delay = dm })
        , Html.div [] [ Html.text <| "Model: " ++ toString model ]
        ]


subscriptions : Model -> Sub Model
subscriptions model =
    Sub.batch
        [ Timer.subscriptions model.timer
            |> Sub.map (flip setTimerModel model)
        ]
