module FullStack exposing (..)

import Pipe exposing (Updater, Pipe, pure)
import Time exposing (Time, second)
import Html exposing (..)
import Html.Events exposing (onClick)


type alias Model =
    { time : Time
    , counter : Int
    }


init : Pipe Model
init =
    pure
        { time = 0
        , counter = 0
        }


simpleUpdater : Updater Model
simpleUpdater m =
    { m | counter = m.counter + 1 }


view : Model -> Html (Updater Model)
view model =
    div []
        [ div [] [ text "Full-stack component" ]
        , div []
            [ span [] [ text "Simple internal method: " ]
            , button [ onClick simpleUpdater ] [ text "+" ]
            ]
        , div [] [ text <| toString model ]
        ]
