module Counter1 exposing (..)

import Html exposing (Html)
import Html.Events


type alias Model =
    { counter : Int
    }


init : Model
init =
    { counter = 0 }


increment : Model -> Model
increment m =
    { m | counter = m.counter + 1 }


decrement : Model -> Model
decrement m =
    { m | counter = m.counter - 1 }


view : Model -> Html (Model -> Model)
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
