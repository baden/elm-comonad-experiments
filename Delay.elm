module Delay exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (disabled)
import Process
import Task
import Time exposing (Time, millisecond)
import Pipe exposing (Updater, Pipe, pure)


type Model
    = Value Int
    | StartDelay
    | DelayInProgress


init : Pipe Model
init =
    pure (Value 0)


after : Time -> msg -> Cmd msg
after time msg =
    Process.sleep time
        |> Task.perform (always msg)


commands : Model -> ( Model, Cmd (Updater Model) )
commands model =
    case model of
        StartDelay ->
            let
                _ =
                    Debug.log "start delay" 0
            in
                ( DelayInProgress, after 3000 (always <| Value 2) )

        DelayInProgress ->
            ( model, Cmd.none )

        Value _ ->
            ( model, Cmd.none )


start_delay : Updater Model
start_delay =
    (always StartDelay)


view : Model -> Html (Updater Model)
view model =
    let
        disabled_key =
            case model of
                Value _ ->
                    False

                _ ->
                    True
    in
        div []
            [ button
                [ onClick start_delay
                , disabled disabled_key
                ]
                [ text "Press me for delayed command" ]
            , span [] [ text <| toString model ]
            ]
