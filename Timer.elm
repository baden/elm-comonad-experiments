module Timer exposing (..)

import Time exposing (Time, second)


type alias Model =
    { time : Time
    }


increment m =
    { m | time = m.time + 1 }


init : Model
init =
    { time = 0
    }


subscriptions : Model -> Sub (Model -> Model)
subscriptions model =
    Time.every second <| always increment
