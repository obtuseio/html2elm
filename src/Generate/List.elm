module Generate.List exposing (..)


type Line
    = Code String
    | Comment String


toString : Line -> String
toString line =
    case line of
        Code value ->
            value

        Comment value ->
            value
                |> String.trim
                |> String.split "\n"
                |> List.map (\line -> "-- " ++ String.trim line)
                |> String.join "\n"


toElm : List Line -> String
toElm lines =
    case lines of
        [] ->
            "[]"

        [ Code value ] ->
            "[ " ++ value ++ " ]"

        [ Comment value ] ->
            "[] " ++ toString (Comment value)

        _ ->
            lines
                |> List.foldl
                    (\line ( lines, ( i, first ) ) ->
                        let
                            prefix =
                                case ( line, i, first ) of
                                    ( _, 0, _ ) ->
                                        ""

                                    ( Comment _, _, _ ) ->
                                        ""

                                    ( _, _, True ) ->
                                        "  "

                                    _ ->
                                        ", "

                            nextFirst =
                                case line of
                                    Comment _ ->
                                        first

                                    _ ->
                                        False
                        in
                        ( lines ++ [ prefix ++ toString line ], ( i + 1, nextFirst ) )
                    )
                    ( [], ( 0, True ) )
                |> Tuple.first
                |> String.join "\n"
                |> (\string -> "[ " ++ string ++ "\n]")
