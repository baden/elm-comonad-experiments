module Counter2 exposing (..)

import Html exposing (Html)
import Html.Events


type alias Model =
    { counter : Int
    }


type alias Config msg =
    { doIt : msg
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


view : Config pmsg -> Model -> Html ( Maybe pmsg, Model -> Model )
view config model =
    Html.div
        []
        [ Html.span []
            [ Html.text "Counter1" ]
        , Html.button
            [ Html.Events.onClick <| ( Nothing, decrement ) ]
            [ Html.text "-" ]
        , Html.span
            []
            [ Html.text <| toString model ]
        , Html.button
            [ Html.Events.onClick <| ( Nothing, increment ) ]
            [ Html.text "+" ]
        , Html.span
            []
            [ Html.text " toParent:" ]
        , Html.button
            [ Html.Events.onClick <| ( Just config.doIt, identity ) ]
            [ Html.text "Do it!" ]
        , Html.span
            []
            [ Html.text " with sideeffect:" ]
        , Html.button
            [ Html.Events.onClick <| ( Just config.doIt, increment ) ]
            [ Html.text "Do it!" ]
        ]
