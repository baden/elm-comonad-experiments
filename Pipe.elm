module Pipe exposing (Updater, program)

import Html exposing (Html)


type alias Updater model =
    model -> model


type alias Program model =
    { commands : model -> Cmd (Updater model)
    , model : model
    , subscriptions : model -> Sub (Updater model)
    , view : model -> Html (Updater model)
    }


{-| Create a program from an alternative program.
-}
program : Program model -> Platform.Program Never model (model -> model)
program { commands, model, subscriptions, view } =
    Html.program
        { init = ( model, commands model )
        , subscriptions = subscriptions
        , update =
            \updater model ->
                -- TODO: Ось тут я трохи сумніваюсь у послідовності
                let
                    new_model =
                        updater model
                in
                    ( new_model, commands new_model )
        , view = view
        }
