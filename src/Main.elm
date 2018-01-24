module Main exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (id)
import Json.Decode exposing (Value)
import Json.Encode
import Ports


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Ports.receive Receive
        }



-- MODEL


type alias Model =
    String


init : ( Model, Cmd Msg )
init =
    "" ! [ Ports.init () ]



-- UPDATE


type Msg
    = Receive Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Receive value ->
            Json.Encode.encode 2 value ! []



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "main" ]
        [ div []
            [ div [ id "html" ] []
            ]
        , div []
            [ div [ id "elm" ] []
            , div [] [ text model ]
            ]
        ]
