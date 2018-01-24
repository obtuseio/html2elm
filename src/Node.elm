module Node exposing (..)


type alias Attribute =
    ( String, String )


type Node
    = Comment String
    | Element String (List Attribute) (List Node)
    | Text String
