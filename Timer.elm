module Timer exposing (..)

import Time exposing (Time, second)
import Html exposing (..)
import Html.Events exposing (onClick)
import Pipe exposing (Updater, Pipe, pure)


type alias Model =
    { time : Time
    }


reset : Model -> Model
reset m =
    { m | time = 0 }


increment : Model -> Model
increment m =
    { m | time = m.time + 1 }


init : Pipe Model
init =
    pure
        { time = 0
        }


subscriptions : Model -> Sub (Updater Model)
subscriptions model =
    Time.every (100 * second) <| always increment


view : Model -> Html (Updater Model)
view model =
    div []
        [ span [] [ text "Timer:" ]
        , span [] [ text <| toString model.time ]
        , button [ onClick reset ] [ text "Reset" ]
        ]
