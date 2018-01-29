module Pipe
    exposing
        ( Updater
        , program
        , Lens
        , lensUpdater
        , view
        , commands
        , subscriptions
        )

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


type alias Lens model value =
    { get : model -> value
    , set : value -> model -> model
    }


lensUpdater : Lens parentmodel childmodel -> Updater childmodel -> Updater parentmodel
lensUpdater lens child_updater =
    \m -> (m |> lens.get |> child_updater |> lens.set) m



-- analogue
-- view view lens model =
--     model
--         |> lens.get
--         |> view
--         |> Html.map (lensUpdater lens)


view :
    (childmodel -> Html (Updater childmodel))
    -> Lens parentmodel childmodel
    -> parentmodel
    -> Html (Updater parentmodel)
view view lens =
    lens.get
        >> view
        >> Html.map (lensUpdater lens)


commands :
    (childmodel -> Cmd (Updater childmodel))
    -> Lens parentmodel childmodel
    -> parentmodel
    -> Cmd (Updater parentmodel)
commands commands lens =
    lens.get
        >> commands
        >> Cmd.map (lensUpdater lens)


subscriptions :
    (childmodel -> Sub (Updater childmodel))
    -> Lens parentmodel childmodel
    -> parentmodel
    -> Sub (Updater parentmodel)
subscriptions subscriptions lens =
    lens.get
        >> subscriptions
        >> Sub.map (lensUpdater lens)
