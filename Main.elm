module Main exposing (main)

import Html exposing (Html)
import Html.Events
import Html exposing (Html)


{-| Pack together the current value along with a computed view of said value.
We can specialize the `a` to be `Html a`
and get something that works for top level programs.
We can also not do that.
We can describe many UIs and they don't have to be `Html a`.
-}
type alias Env e a =
    { here : e
    , view : a
    }


{-| Transform the view.
Useful when you want to change the view of an already defined env.
-}
map : (a -> b) -> Env e a -> Env e b
map f env =
    { env | view = f env.view }


{-| Replace the view.
A common pattern is to just replace the old view without depending on it:
`set x = map (\_ -> x)`
-}
set : b -> Env s a -> Env s b
set b env =
    { env | view = b }


{-| Create a new env where the view is another env.
Gives us the lazy unfolding of all future states of a given env.
-}
duplicate : Env e a -> Env e (Env e a)
duplicate env =
    { env | view = env }


{-| View the current value.
-}
extract : Env e a -> a
extract env =
    env.view


{-| Move to the new given value.
This is how we make progress in the UI.
-}
move : e -> Env e a -> Env e a
move e env =
    case duplicate env of
        { view } ->
            { view | here = e }


toBeginnerProgram :
    Env e (e -> Html a)
    -> { model : Env e (e -> Html a)
       , update : e -> Env e (e -> Html a) -> Env e (e -> Html a)
       , view : Env e (e -> Html a) -> Html a
       }
toBeginnerProgram env =
    { model = env
    , update = move
    , view = \env -> extract env env.here
    }



-- Application


type alias Model =
    { counter : Int }


init : Model
init =
    { counter = 0
    }


main : Program Never (Env Model (Model -> Html Model)) Model
main =
    Html.beginnerProgram
        (toBeginnerProgram { here = init, view = view })


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
