module Pipe
    exposing
        ( Updater
        , program
        , Lens
        , lensUpdater
        , view
          -- , command
          -- , subscriptions
        , Pipe
        , pure
        , Worker
        , modify
        , set
        )

import Html exposing (Html)


type alias Updater model =
    model -> model


type alias Pipe model =
    ( model, Cmd (Updater model) )


pure : model -> Pipe model
pure model =
    ( model, Cmd.none )


type alias Worker model =
    ( Updater model, Cmd (Updater model) )


modify : Updater model -> Worker model
modify f =
    ( f, Cmd.none )


set : model -> Worker model
set m =
    ( always m, Cmd.none )


type alias Program model =
    { --commands : model -> ( model, Cmd (Updater model) )
      init : Pipe model
    , subscriptions : model -> Sub (Updater model)
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
            in
                ( init_model, Cmd.none )

        -- always (model, Cmd.none)
        , subscriptions = always Sub.none

        -- , subscriptions = subscriptions
        , update =
            \( updater, cmd ) model ->
                let
                    _ =
                        Debug.log "new updater" ( updater, cmd, model )

                    nm =
                        updater model

                    _ =
                        Debug.log "new model" (nm)
                in
                    ( nm, Cmd.none )
        , view = view
        }


type alias Lens model value =
    { get : model -> value
    , set : value -> model -> model
    }


lensUpdater : Lens parentmodel childmodel -> Updater childmodel -> Updater parentmodel
lensUpdater lens child_updater =
    -- \m -> (m |> lens.get |> child_updater |> lens.set) m
    \m ->
        lens.set (child_updater (lens.get m)) m


lensUpdaterW : Lens parentmodel childmodel -> Worker childmodel -> Worker parentmodel
lensUpdaterW lens ( child_updater, child_cmd ) =
    ( \m ->
        let
            _ =
                Debug.log "---updater" m
        in
            lens.set (child_updater (lens.get m)) m
    , Cmd.none
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
-- subscriptions :
--     (childmodel -> Sub (Updater childmodel))
--     -> Lens parentmodel childmodel
--     -> parentmodel
--     -> Sub (Updater parentmodel)
-- subscriptions subscriptions lens =
--     lens.get
--         >> subscriptions
--         >> Sub.map (lensUpdater lens)
