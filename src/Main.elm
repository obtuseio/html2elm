module Main exposing (..)

import Generate
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, classList, id)
import Html.Events exposing (onClick)
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
    { node : Node
    , options : Generate.Options
    }


init : ( Model, Cmd Msg )
init =
    Model (Node.Text "") Generate.default ! [ Ports.init () ]



-- UPDATE


type Msg
    = Receive Value
    | Toggle Generate.Option


refresh : Model -> ( Model, Cmd Msg )
refresh model =
    model ! [ Ports.send <| Generate.generate model.node model.options ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Receive value ->
            case Node.decodeValue value of
                Ok node ->
                    refresh { model | node = node }

                -- This should never be triggered.
                Err _ ->
                    model ! []

        Toggle option ->
            refresh { model | options = Generate.toggle option model.options }



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "main", class "column" ]
        [ div [ id "header", class "row middle" ]
            [ h1 [ class "expand" ] [ text "html2elm.obtuse.io" ]
            , div []
                [ div
                    [ class "ui tiny button"
                    , classList [ ( "green", model.options.removeEmpty ) ]
                    , onClick (Toggle Generate.RemoveEmpty)
                    ]
                    [ text "Remove Empty Text Nodes?" ]
                , div
                    [ class "ui tiny button"
                    , classList [ ( "green", model.options.trim ) ]
                    , onClick (Toggle Generate.Trim)
                    ]
                    [ text "Trim Text Nodes?" ]
                , div
                    [ class "ui tiny button"
                    , classList [ ( "green", model.options.collapse ) ]
                    , onClick (Toggle Generate.Collapse)
                    ]
                    [ text "Collapse Consecutive Whitespace in Text Nodes?" ]
                ]
            ]
        , div [ class "row expand" ]
            [ div [ id "html", class "expand" ] []
            , div [ id "elm", class "expand" ] []
            ]
        ]
