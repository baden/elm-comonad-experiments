module Counter2 exposing (..)

import Html exposing (Html)
import Html.Events
import Pipe exposing (Updater, Pipe, pure)


type alias Model =
    { counter : Int
    }


type alias Config msg =
    { doIt : msg
    }


init : Pipe Model
init =
    pure { counter = 2 }


increment : Updater Model
increment m =
    { m | counter = m.counter + 1 }


decrement : Updater Model
decrement m =
    { m | counter = m.counter - 1 }


view : Config pmsg -> Model -> Html ( Maybe pmsg, Updater Model )
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
