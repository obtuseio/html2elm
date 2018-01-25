module Node exposing (..)

import Json.Decode as Decode exposing (Decoder, Value)


type alias Attribute =
    ( String, String )


type alias Style =
    ( String, String )


type Node
    = Comment String
    | Element String (List Attribute) (List Style) (List Node)
    | Text String


decodeValue : Value -> Result String Node
decodeValue =
    Decode.decodeValue decoder


attributeOrStyleDecoder : Decoder ( String, String )
attributeOrStyleDecoder =
    Decode.map2 (,)
        (Decode.field "name" Decode.string)
        (Decode.field "value" Decode.string)


decoder : Decoder Node
decoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\type_ ->
                case type_ of
                    "comment" ->
                        Decode.map Comment <| Decode.field "value" Decode.string

                    "element" ->
                        Decode.map4 Element
                            (Decode.field "name" Decode.string)
                            (Decode.field "attributes" (Decode.list attributeOrStyleDecoder))
                            (Decode.field "styles" (Decode.list attributeOrStyleDecoder))
                            (Decode.field "children" (Decode.list decoder))

                    "text" ->
                        Decode.map Text <| Decode.field "value" Decode.string

                    _ ->
                        Decode.fail "this is impossible!"
            )
