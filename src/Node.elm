module Node exposing (..)

import Json.Decode as Decode exposing (Decoder, Value)


type alias Attribute =
    ( String, String )


type Node
    = Comment String
    | Element String (List Attribute) (List Node)
    | Text String


decodeValue : Value -> Result String Node
decodeValue =
    Decode.decodeValue decoder


attributeDecoder : Decoder Attribute
attributeDecoder =
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
                        Decode.map3 Element
                            (Decode.field "name" Decode.string)
                            (Decode.field "attributes" (Decode.list attributeDecoder))
                            (Decode.field "children" (Decode.list decoder))

                    "text" ->
                        Decode.map Text <| Decode.field "value" Decode.string

                    _ ->
                        Decode.fail "this is impossible!"
            )
