module Generate exposing (..)

import Node exposing (..)
import Regex


type alias Options =
    { removeEmpty : Bool
    , trim : Bool
    , collapse : Bool
    }


type Option
    = RemoveEmpty
    | Trim
    | Collapse


toggle : Option -> Options -> Options
toggle option options =
    case option of
        RemoveEmpty ->
            { options | removeEmpty = not options.removeEmpty }

        Trim ->
            { options | trim = not options.trim }

        Collapse ->
            { options | collapse = not options.collapse }


default : Options
default =
    Options True True False


generate : Node -> Options -> String
generate node options =
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
                        |> List.map
                            (\node ->
                                case ( options.trim, node ) of
                                    ( True, Text value ) ->
                                        Text <| String.trim value

                                    _ ->
                                        node
                            )
                        |> List.filter
                            (\node ->
                                case ( options.removeEmpty, node ) of
                                    ( True, Text value ) ->
                                        String.trim value /= ""

                                    _ ->
                                        True
                            )
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
                                prefix ++ generate node options
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
            "text "
                ++ toString
                    (if options.collapse then
                        collapse value
                     else
                        value
                    )


indent : String -> String
indent string =
    string
        |> String.split "\n"
        |> List.map (\line -> "    " ++ line)
        |> String.join "\n"


collapse : String -> String
collapse =
    Regex.replace Regex.All (Regex.regex "\\s+") (\_ -> " ")
