port module Ports exposing (..)

import Json.Decode exposing (Value)


port init : () -> Cmd msg


port receive : (Value -> msg) -> Sub msg


port send : String -> Cmd msg
