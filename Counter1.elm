module Counter1 exposing (..)

import Pipe exposing (Updater, Pipe, pure)
import Html exposing (Html)
import Html.Events


type alias Model =
    { counter : Int
    }


init : Pipe Model
init =
    pure { counter = 1 }


increment : Updater Model
increment m =
    { m | counter = m.counter + 1 }


decrement : Updater Model
decrement m =
    { m | counter = m.counter - 1 }


view : Model -> Html (Updater Model)
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
        ]
