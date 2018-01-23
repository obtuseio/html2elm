module Main exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (id)
import Ports


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }



-- MODEL


type alias Model =
    ()


init : ( Model, Cmd Msg )
init =
    () ! [ Ports.init () ]



-- UPDATE


type Msg
    = Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    model ! []



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "main" ]
        [ div [ id "html" ] []
        , div [ id "elm" ] []
        ]
