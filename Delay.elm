module Delay exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)
import Process
import Task
import Time exposing (Time, millisecond)
import Pipe exposing (Updater, Pipe, pure, Worker, modify)


type State
    = Init
    | Started
    | Done


type alias Model =
    { state : State
    , value : Int
    }


init : Pipe Model
init =
    -- pure (Model Init 0)
    ( Model Init 0
    , after 3000 endDelay
      --     (\m ->
      --         let
      --             _ =
      --                 Debug.log "WTF?" m
      --         in
      --             m
      --     )
    )


after : Time -> msg -> Cmd msg
after time msg =
    Process.sleep time
        |> Task.perform (always msg)


startDelay : Worker Model
startDelay =
    ( \m -> { m | state = Started }
      -- , after 3000 endDelay
    , after 3000
        (\m ->
            let
                _ =
                    Debug.log "WTF?" m
            in
                m
        )
      -- , Cmd.none
    )


endDelay : Worker Model
endDelay =
    modify (\m -> { m | state = Done })



-- commands : Model -> ( Model, Cmd (Updater Model) )
-- commands model =
--     case model of
--         StartDelay ->
--             let
--                 _ =
--                     Debug.log "start delay" 0
--             in
--                 ( DelayInProgress, after 3000 (always <| Value 2) )
--
--         DelayInProgress ->
--             ( model, Cmd.none )
--
--         Value _ ->
--             ( model, Cmd.none )
-- start_delay : Updater Model
-- start_delay =
--     (always StartDelay)


view : Model -> Html (Worker Model)
view model =
    div []
        [ button
            [ onClick startDelay
            , disabled (model.state == Started)
            ]
            [ text "Press me for delayed command" ]
        , span [] [ text <| toString model ]
        ]
