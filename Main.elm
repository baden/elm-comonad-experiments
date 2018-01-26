module Main exposing (main)

import Html exposing (Html)
import Html.Events
import Html exposing (Html)


{-| Pack together the current value along with a function to view said value.
We can specialize the `a` to be `Html a`
and get something that works for top level programs.
We can also not do that.
We can describe many UIs and they don't have to be `Html a`.
-}
type alias Store s a =
    { here : s
    , view : s -> a
    }


{-| Transform the view.
Useful when you want to change the view of an already defined store.
-}
map : (a -> b) -> Store s a -> Store s b
map f store =
    { store | view = f << store.view }


{-| Replace the view.
A common pattern is to just replace the old view without depending on it:
`set x = map (\_ -> x)`
-}
set : b -> Store m a -> Store m b
set b store =
    { store | view = always b }


{-| Create a new store where the view is another store.
Gives us the lazy unfolding of all future states of a given store.
-}
duplicate : Store s a -> Store s (Store s a)
duplicate store =
    { store | view = \next -> { here = next, view = store.view } }


{-| View the current value.
-}
extract : Store s a -> a
extract store =
    store.view store.here


{-| Move to the new given value.
This is how we make progress in the UI.
-}
move : s -> Store s a -> Store s a
move s store =
    (duplicate store).view s


toBeginnerProgram :
    Store s (Html a)
    -> { model : Store s (Html a)
       , update : s -> Store s (Html a) -> Store s (Html a)
       , view : Store s (Html a) -> Html a
       }
toBeginnerProgram store =
    { model = store
    , update = move
    , view = extract
    }



-- toProgram :
--     Store s (Html a)
--     -> { model : Store s (Html a)
--        , update : s -> Store s (Html a) -> Store s (Html a)
--        , view : Store s (Html a) -> Html a
--        }


toProgram store =
    { init = store ! []
    , update = \msg model -> move msg model ! []
    , view = extract
    , subscriptions = subscriptions
    }



-- Application
-- main : Program Never (Env Model (Model -> Html Model)) Model


beginnerProgram2 :
    { model : model
    , view : model -> Html msg
    , update : msg -> model -> model
    }
    -> Program Never model msg
beginnerProgram2 { model, view, update } =
    Html.program
        { init = model ! []
        , update = \msg model -> update msg model ! []
        , view = view
        , subscriptions = subscriptions
        }


main : Program Never (Store Model (Html Model)) Model
main =
    -- beginnerProgram2
    --     (toBeginnerProgram { here = init, view = view })
    Html.program <|
        toProgram
            { here = init, view = view }


type alias Model =
    { counter : Int }


subscriptions s =
    let
        _ =
            Debug.log "s=" s
    in
        Sub.none


init : Model
init =
    { counter = 0
    }


increment : Model -> Model
increment m =
    { m | counter = m.counter + 1 }


decrement : Model -> Model
decrement m =
    { m | counter = m.counter - 1 }


view : Model -> Html Model
view model =
    Html.div
        []
        [ Html.button
            [ Html.Events.onClick (decrement model) ]
            [ Html.text "-" ]
        , Html.div
            []
            [ Html.text <| toString model ]
        , Html.button
            [ Html.Events.onClick (increment model) ]
            [ Html.text "+" ]
        ]
