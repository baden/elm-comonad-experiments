module Pipe
    exposing
        ( Updater
        , program
        , Lens
        , lensUpdater
        , view
        , command
        , subscriptions
        )

import Html exposing (Html)


type alias Updater model =
    model -> model


type alias Program model =
    { commands : model -> ( model, Cmd (Updater model) )
    , model : model
    , subscriptions : model -> Sub (Updater model)
    , view : model -> Html (Updater model)
    }


{-| Create a program from an alternative program.
-}
program : Program model -> Platform.Program Never model (model -> model)
program { commands, model, subscriptions, view } =
    Html.program
        { init =
            let
                ( new_model, cmds ) =
                    commands model
            in
                ( new_model, cmds )
        , subscriptions = subscriptions
        , update =
            \updater model ->
                -- TODO: Ось тут я трохи сумніваюсь у послідовності
                let
                    ( new_model, cmds ) =
                        commands (updater model)
                in
                    ( new_model, cmds )
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



-- lensUpdater : Lens parentmodel childmodel -> Updater childmodel -> Updater parentmodel
-- lensUpdater lens child_updater =
--     \m -> (m |> lens.get |> child_updater |> lens.set) m


command :
    (childmodel -> ( childmodel, Cmd (Updater childmodel) ))
    -> Lens parentmodel childmodel
    -> ( parentmodel, Cmd (Updater parentmodel) )
    -> ( parentmodel, Cmd (Updater parentmodel) )
command commands lens ( model, cmds ) =
    let
        ( chmodel, chcmd ) =
            model |> lens.get |> commands
    in
        ( lens.set chmodel model
        , chcmd |> Cmd.map (lensUpdater lens)
        )


subscriptions :
    (childmodel -> Sub (Updater childmodel))
    -> Lens parentmodel childmodel
    -> parentmodel
    -> Sub (Updater parentmodel)
subscriptions subscriptions lens =
    lens.get
        >> subscriptions
        >> Sub.map (lensUpdater lens)
