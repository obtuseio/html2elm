module Main exposing (..)

import Generate
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, id)
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
    ()


init : ( Model, Cmd Msg )
init =
    () ! [ Ports.init () ]



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

                -- This should never be triggered.
                Err _ ->
                    model ! []



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "main", class "column" ]
        [ div [ id "header", class "row middle" ]
            [ h1 [ class "expand" ] [ text "html2elm.obtuse.io" ]
            , div []
                [ div [ class "ui tiny green button" ] [ text "Remove Empty Text Nodes?" ]
                , div [ class "ui tiny button" ] [ text "Collapse Consecutive Whitespace in Text Nodes?" ]
                ]
            ]
        , div [ class "row expand" ]
            [ div [ id "html", class "expand" ] []
            , div [ id "elm", class "expand" ] []
            ]
        ]
