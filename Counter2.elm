module Counter2 exposing (..)

import Pipe exposing (Updater, Pipe, pure, Worker, modify)
import Html exposing (Html)
import Html.Events


type alias Model =
    { counter : Int
    }


type alias Config msg =
    { doIt : msg
    }


init : Pipe Model
init =
    pure { counter = 2 }


increment : Worker Model
increment =
    modify (\m -> { m | counter = m.counter + 1 })


decrement : Worker Model
decrement =
    modify (\m -> { m | counter = m.counter - 1 })


ident : Worker Model
ident =
    modify (\m -> m)


view : Config pmsg -> Model -> Html ( Maybe pmsg, Worker Model )
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
            [ Html.Events.onClick <| ( Just config.doIt, ident ) ]
            [ Html.text "Do it!" ]
        , Html.span
            []
            [ Html.text " with sideeffect:" ]
        , Html.button
            [ Html.Events.onClick <| ( Just config.doIt, increment ) ]
            [ Html.text "Do it!" ]
        ]
