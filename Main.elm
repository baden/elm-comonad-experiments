module Main exposing (main)

import Html exposing (Html)
import Html.Events
import Time exposing (Time, second)


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



-- Application


main : Platform.Program Never Model Model
main =
    program
        { commands = \m -> Cmd.none
        , model = Model 0 0
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { counter : Int
    , time : Time
    }


subscriptions : Model -> Sub Model
subscriptions model =
    -- Time.every second (\t -> setTime t model)
    Time.every second (flip setTime model)


init : Model
init =
    { counter = 0
    , time = 0
    }


increment : Model -> Model
increment m =
    { m | counter = m.counter + 1 }


decrement : Model -> Model
decrement m =
    { m | counter = m.counter - 1 }


setTime : Time -> Model -> Model
setTime t m =
    { m | time = t }


view : Model -> Html Model
view model =
    Html.div
        []
        [ Html.button
            [ Html.Events.onClick (decrement model) ]
            [ Html.text "-" ]
        , Html.div
            []
            [ Html.text <| toString model ]
        , Html.button
            [ Html.Events.onClick (increment model) ]
            [ Html.text "+" ]
        ]
