module Timer exposing (..)

import Time exposing (Time, second)
import Html exposing (..)
import Html.Events exposing (onClick)
import Pipe exposing (Updater, Pipe, pure, Worker, modify, set)


type alias Model =
    { time : Time
    }


reset : Worker Model
reset =
    set { time = 0 }


increment : Worker Model
increment =
    modify (\m -> { m | time = m.time + 1 })


init : Pipe Model
init =
    pure { time = 0 }


subscriptions : Model -> Sub (Worker Model)
subscriptions model =
    Time.every (100 * second) <| always increment


view : Model -> Html (Worker Model)
view model =
    div []
        [ span [] [ text "Timer:" ]
        , span [] [ text <| toString model.time ]
        , button [ onClick reset ] [ text "Reset" ]
        ]
