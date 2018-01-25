module Generate exposing (..)

import Node exposing (..)
import Regex
import Set exposing (Set)


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
                    -- Special case.
                    if name == "main" then
                        "main_"
                    else if Set.member name elements then
                        name
                    else
                        "node " ++ toString name

                b =
                    attributes
                        |> List.map
                            (\( name, value ) ->
                                if name == "type" then
                                    "type_ " ++ toString value
                                else if Set.member name stringAttributes then
                                    name ++ " " ++ toString value
                                else if Set.member name intAttributes then
                                    case String.toInt value of
                                        Ok int ->
                                            name ++ " " ++ toString int

                                        Err _ ->
                                            "attribute " ++ toString name ++ " " ++ toString value
                                else if Set.member name boolAttributes then
                                    name ++ " True"
                                else
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



-- From https://github.com/elm-lang/html/blob/76b88764512b0469182717609406fa9a224d253d/src/Html.elm#L5-L20
-- $ curl https://raw.githubusercontent.com/elm-lang/html/76b88764512b0469182717609406fa9a224d253d/src/Html.elm | \
--   grep '^[a-zA-Z0-9]\+ : List (Attribute msg) -> List (Html msg) -> Html msg$' | \
--   cut -d: -f1 | sort | xargs


elements : Set String
elements =
    Set.fromList <| String.words <| """
        a abbr address article aside audio b bdi bdo blockquote body br
        button canvas caption cite code col colgroup datalist dd del details
        dfn div dl dt em embed fieldset figcaption figure footer form h1 h2
        h3 h4 h5 h6 header hr i iframe img input ins kbd keygen label legend
        li mark math menu menuitem meter nav object ol optgroup option output
        p param pre progress q rp rt ruby s samp section select small source
        span strong sub summary sup table tbody td textarea tfoot th thead
        time tr track u ul var video wbr
    """



-- $ curl https://raw.githubusercontent.com/elm-lang/html/76b88764512b0469182717609406fa9a224d253d/src/Html/Attributes.elm | \
--   grep '^[a-zA-Z]\+ : String -> Attribute msg$' | \
--   cut -d: -f1 | sort | xargs


stringAttributes : Set String
stringAttributes =
    Set.fromList <| String.words <| """
        accept acceptCharset action align alt challenge charset cite class
        content contextmenu coords datetime defaultValue dir downloadAs
        draggable dropzone enctype for form formaction headers href hreflang
        httpEquiv id itemprop keytype kind label lang language list manifest max
        media method min name pattern ping placeholder poster preload pubdate
        rel sandbox scope shape src srcdoc srclang step target title usemap
        value wrap
    """



-- $ curl https://raw.githubusercontent.com/elm-lang/html/76b88764512b0469182717609406fa9a224d253d/src/Html/Attributes.elm | \
--   grep '^[a-zA-Z]\+ : Int -> Attribute msg$' | \
--   cut -d: -f1 | sort | xargs


intAttributes : Set String
intAttributes =
    Set.fromList <| String.words <| """
        cols colspan height maxlength minlength rows rowspan size span start
        tabindex width
    """



-- $ curl https://raw.githubusercontent.com/elm-lang/html/76b88764512b0469182717609406fa9a224d253d/src/Html/Attributes.elm | \
--   grep '^[a-zA-Z]\+ : Bool -> Attribute msg$' | \
--   cut -d: -f1 | sort | xargs


boolAttributes : Set String
boolAttributes =
    Set.fromList <| String.words <| """
        async autocomplete autofocus autoplay checked contenteditable
        controls default defer disabled download hidden ismap loop multiple
        novalidate readonly required reversed scoped seamless selected
        spellcheck
    """


indent : String -> String
indent string =
    string
        |> String.split "\n"
        |> List.map (\line -> "    " ++ line)
        |> String.join "\n"


collapse : String -> String
collapse =
    Regex.replace Regex.All (Regex.regex "\\s+") (\_ -> " ")
