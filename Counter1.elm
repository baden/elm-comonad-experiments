module Counter1 exposing (..)

import Pipe exposing (Updater, Pipe, pure, Worker, modify, set)
import Html exposing (Html)
import Html.Events


type alias Model =
    { counter : Int
    }


init : Pipe Model
init =
    pure { counter = 1 }


increment : Worker Model
increment =
    modify (\m -> { m | counter = m.counter + 1 })


decrement : Worker Model
decrement =
    modify (\m -> { m | counter = m.counter - 1 })


reset : Worker Model
reset =
    set { counter = 0 }


view : Model -> Html (Worker Model)
view model =
    Html.div
        []
        [ Html.span []
            [ Html.text "Counter1" ]
        , Html.button
            [ Html.Events.onClick decrement ]
            [ Html.text "-" ]
        , Html.span
            []
            [ Html.text <| toString model ]
        , Html.button
            [ Html.Events.onClick increment ]
            [ Html.text "+" ]
        , Html.button
            [ Html.Events.onClick reset ]
            [ Html.text "Clear" ]
        ]
