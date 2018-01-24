module Generate exposing (generate)

import Node exposing (..)


generate : Node -> String
generate node =
    case node of
        Comment value ->
            value
                |> String.split "\n"
                |> List.map (\line -> "-- " ++ String.trim line)
                |> String.join "\n"

        Element name attributes children ->
            let
                a =
                    "node " ++ toString name

                b =
                    attributes
                        |> List.map
                            (\( name, value ) ->
                                "attribute " ++ toString name ++ " " ++ toString value
                            )
                        |> String.join ", "

                c =
                    children
                        |> List.indexedMap
                            (\i node ->
                                let
                                    prefix =
                                        case ( i, node ) of
                                            ( 0, _ ) ->
                                                ""

                                            ( _, Comment _ ) ->
                                                ""

                                            _ ->
                                                ", "
                                in
                                prefix ++ generate node
                            )
                        |> String.join "\n"

                nested string newline =
                    indent <|
                        case ( string, newline ) of
                            ( "", _ ) ->
                                "[]"

                            ( _, False ) ->
                                "[ " ++ string ++ " ]"

                            ( _, True ) ->
                                "[ " ++ string ++ "\n]"
            in
            [ a, nested b False, nested c True ] |> String.join "\n"

        Text value ->
            "text " ++ toString value


indent : String -> String
indent string =
    string
        |> String.split "\n"
        |> List.map (\line -> "    " ++ line)
        |> String.join "\n"
