module Main exposing (..)

import Generate
import Html exposing (Html, div, text)
import Html.Attributes exposing (id)
import Json.Decode exposing (Value)
import Node exposing (Node)
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
    { error : Maybe String
    }


init : ( Model, Cmd Msg )
init =
    { error = Nothing } ! [ Ports.init () ]



-- UPDATE


type Msg
    = Receive Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Receive value ->
            case Node.decodeValue value of
                Ok node ->
                    model ! [ Ports.send <| Generate.generate node ]

                Err error ->
                    { model | error = Just error } ! []



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "main" ]
        [ div []
            [ div [ id "html" ] []
            ]
        , div []
            [ div [ id "elm" ] []
            , div [] [ text <| toString model ]
            ]
        ]
