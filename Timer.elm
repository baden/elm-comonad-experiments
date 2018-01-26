module Timer exposing (..)

import Time exposing (Time, second)


type alias Model =
    { time : Time
    }


setTime : Time -> Model -> Model
setTime t m =
    { m | time = t }


init : Model
init =
    { time = 0
    }


subscriptions : Model -> Sub Model
subscriptions model =
    -- Time.every second (\t -> setTime t model)
    Time.every second (flip setTime model)
