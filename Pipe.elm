module Pipe
    exposing
        ( Updater
        , program
        , Lens
        , lensUpdater
        , view
        , map
          -- , command
        , subscriptions
        , Pipe
        , pure
        , full
        , Worker
        , modify
        , modify_and_cmd
        , set
        , WorkerCmds
        )

import Html exposing (Html)


type alias Updater model =
    model -> model


type alias Pipe model =
    ( model, Cmd (Worker model) )


pure : model -> Pipe model
pure model =
    ( model, Cmd.none )


full : model -> Cmd (Worker model) -> Pipe model
full model cmd =
    ( model, cmd )


type alias Worker model =
    ( Updater model, WorkerCmds model )


type WorkerCmds model
    = WorkerCmds (Cmd (Worker model))


modify : Updater model -> Worker model
modify f =
    ( f, WorkerCmds Cmd.none )


set : model -> Worker model
set m =
    ( always m, WorkerCmds Cmd.none )


modify_and_cmd : Updater model -> Cmd (Worker model) -> Worker model
modify_and_cmd f c =
    ( f, WorkerCmds c )


type alias Program model =
    { init : Pipe model
    , subscriptions : model -> Sub (Worker model)
    , view : model -> Html (Worker model)
    }


{-| Create a program from an alternative program.
-}
program : Program model -> Platform.Program Never model (Worker model)
program { init, subscriptions, view } =
    Html.program
        { init =
            let
                ( init_model, init_cmds ) =
                    init

                _ =
                    Debug.log "init " init
            in
                ( init_model, init_cmds )
        , subscriptions = subscriptions
        , update =
            \( updater, WorkerCmds cmd ) model ->
                ( updater model, cmd )
        , view = view
        }


type alias Lens model value =
    { get : model -> value
    , set : value -> model -> model
    }


lensUpdater : Lens parentmodel childmodel -> Updater childmodel -> Updater parentmodel
lensUpdater lens child_updater =
    \m -> (m |> lens.get |> child_updater |> lens.set) m


lensUpdaterW : Lens parentmodel childmodel -> Worker childmodel -> Worker parentmodel
lensUpdaterW lens ( child_updater, WorkerCmds child_cmd ) =
    ( child_updater |> lensUpdater lens
    , child_cmd
        |> Cmd.map (lensUpdaterW lens)
        |> WorkerCmds
    )


map : Lens parentmodel childmodel -> Cmd (Worker childmodel) -> Cmd (Worker parentmodel)
map lens =
    Cmd.map (lensUpdaterW lens)


view :
    (childmodel -> Html (Worker childmodel))
    -> Lens parentmodel childmodel
    -> parentmodel
    -> Html (Worker parentmodel)
view view lens =
    lens.get
        >> view
        >> Html.map (lensUpdaterW lens)


subscriptions :
    (childmodel -> Sub (Worker childmodel))
    -> Lens parentmodel childmodel
    -> parentmodel
    -> Sub (Worker parentmodel)
subscriptions subscriptions lens =
    lens.get
        >> subscriptions
        >> Sub.map (lensUpdaterW lens)
