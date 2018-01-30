module Pipe
    exposing
        ( Updater
        , program
        , Lens
        , lensUpdater
        , view
          -- , command
        , subscriptions
        , Pipe
        , pure
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



-- type alias Worker model =
--     ( Updater model, Cmd (Worker model) )


type alias Worker model =
    ( Updater model, WorkerCmds model )



-- type alias Worker model =
--     { updater : Updater model
--     , cmds : WorkerCmds model
--     }


type WorkerCmds model
    = WorkerCmds (Cmd (Worker model))



-- type Worker model
--     = Worker (_Tuple2 (Updater model) (Cmd (Worker model)))


modify : Updater model -> Worker model
modify f =
    ( f, WorkerCmds Cmd.none )


modify_and_cmd : Updater model -> Cmd (Worker model) -> Worker model
modify_and_cmd f c =
    ( f, WorkerCmds c )


set : model -> Worker model
set m =
    ( always m, WorkerCmds Cmd.none )


type alias Program model =
    { --commands : model -> ( model, Cmd (Updater model) )
      init : Pipe model
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

        -- always (model, Cmd.none)
        -- , subscriptions = always Sub.none
        , subscriptions = subscriptions

        -- update : Worker model -> model -> Worker model
        , update =
            \( updater, WorkerCmds cmd ) model ->
                let
                    _ =
                        Debug.log "new updater" 0

                    nm =
                        updater model

                    _ =
                        Debug.log "new model" (nm)

                    _ =
                        Debug.log "cmd" cmd

                    _ =
                        Debug.log "cmd_none" Cmd.none

                    --     let
                    --         ( chmodel, chcmd ) =
                    --             model |> lens.get |> commands
                    --     in
                    --         ( lens.set chmodel model
                    --         , chcmd |> Cmd.map (lensUpdater lens)
                    --         )
                in
                    ( nm, cmd )

        -- ( nm, cmd )
        -- ( nm, cmd |> Cmd.map (\( m, c ) -> m) )
        , view = view
        }


type alias Lens model value =
    { get : model -> value
    , set : value -> model -> model
    }


lensUpdater : Lens parentmodel childmodel -> Updater childmodel -> Updater parentmodel
lensUpdater lens child_updater =
    \m -> (m |> lens.get |> child_updater |> lens.set) m



-- \m ->
--     lens.set (child_updater (lens.get m)) m


lensUpdaterW : Lens parentmodel childmodel -> Worker childmodel -> Worker parentmodel
lensUpdaterW lens ( child_updater, WorkerCmds child_cmd ) =
    ( child_updater |> lensUpdater lens
    , child_cmd
        |> Cmd.map (lensUpdaterW lens)
        |> WorkerCmds
    )



-- analogue
-- view view lens model =
--     model
--         |> lens.get
--         |> view
--         |> Html.map (lensUpdater lens)


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



-- lensUpdater : Lens parentmodel childmodel -> Updater childmodel -> Updater parentmodel
-- lensUpdater lens child_updater =
--     \m -> (m |> lens.get |> child_updater |> lens.set) m
-- command :
--     (childmodel -> ( childmodel, Cmd (Updater childmodel) ))
--     -> Lens parentmodel childmodel
--     -> ( parentmodel, Cmd (Updater parentmodel) )
--     -> ( parentmodel, Cmd (Updater parentmodel) )
-- command commands lens ( model, cmds ) =
--     let
--         ( chmodel, chcmd ) =
--             model |> lens.get |> commands
--     in
--         ( lens.set chmodel model
--         , chcmd |> Cmd.map (lensUpdater lens)
--         )
--
--
