module Main exposing (main)

import Html exposing (Html)


-- import Html.Events

import Counter1
import Timer


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
    , timer : Timer.Model
    }


commands : Model -> Cmd Model
commands model =
    let
        _ =
            Debug.log "commands" model
    in
        Cmd.none


init : Model
init =
    { counter1 = Counter1.init
    , timer = Timer.init
    }


setCounter1Model : Counter1.Model -> Model -> Model
setCounter1Model cm model =
    { model | counter1 = cm }


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
        , Html.div [] [ Html.text <| "Model: " ++ toString model ]
        ]


subscriptions : Model -> Sub Model
subscriptions model =
    Sub.batch
        [ Timer.subscriptions model.timer
            |> Sub.map (flip setTimerModel model)
        ]
