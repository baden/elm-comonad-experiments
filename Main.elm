module Main exposing (..)

import Html exposing (Html, div, button, text)
import Html.Events exposing (onClick)
import Time exposing (Time, second)


type alias Model =
    { counter : Int
    , time : Time
    }


init : Model
init =
    { counter = 0
    , time = 0
    }


init1 : ( Model, Cmd Msg )
init1 =
    ( init, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init1
        , view = view
        , update = update1
        , subscriptions = subscriptions
        }


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (toString model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]


type Msg
    = Increment
    | Decrement
    | Tick Time


increment : Model -> Model
increment m =
    { m | counter = m.counter + 1 }


decrement : Model -> Model
decrement m =
    { m | counter = m.counter - 1 }


setTime : Time -> Model -> Model
setTime t m =
    { m | time = t }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            increment model

        Decrement ->
            decrement model

        Tick t ->
            setTime t model


update1 : Msg -> Model -> ( Model, Cmd Msg )
update1 msg model =
    ( update msg model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every second Tick
