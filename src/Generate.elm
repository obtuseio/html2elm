module Generate exposing (generate)

import Node exposing (..)


generate : Node -> String
generate node =
    toString node
