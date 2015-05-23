-- A program to display how one is feeling overall in the last 2 days.
-- Data is fetched from Heroku Dataclips.

import Signal
import Signal exposing (Signal, Mailbox)
import Task
import Task exposing (Task, andThen)
import Json.Decode  as J
import Json.Decode exposing ((:=))

import Http
import Html exposing (..)
import Html.Attributes exposing (..)


-- View

view : Maybe DataClip -> Html
view maybeModel =
  case maybeModel of
    Nothing       -> em [] [ text "nothing to show" ]
    Just dataClip -> div [] <| List.map (\f -> b [] [ text f ]) dataClip.fields

-- Dataclip

type alias DataClip =
  { fields : List String
  , types  : List Int
  , values : List (Int, String)
  }

-- JSON decoder

decodeDataClip : J.Decoder DataClip
decodeDataClip = DataClip
  `J.map`  ("fields"   := J.list J.string)
  `andMap` ("types"    := J.list J.int)
  `andMap` ("values"   := J.list decodePair)

decodePair : J.Decoder (Int, String)
decodePair = J.tuple2 (,) J.int J.string

-- Fetching

dataClipUrl : String
dataClipUrl = "https://dataclips.heroku.com/zeitqcftkvfinkxxbhjvznzugbqj.json"

-- FIXME: CORS prevention for some reason.
fetch : Task Http.Error DataClip
fetch =
  Http.get decodeDataClip dataClipUrl

-- Elm machinary

mainTask : Task Http.Error ()
mainTask =
  fetch `andThen` (Just >> Signal.send model.address)

model : Mailbox (Maybe DataClip)
model =
  Signal.mailbox Nothing

port mainPort : Signal (Task Http.Error ())
port mainPort =
  Signal.mailbox mainTask |> .signal

main : Signal Html
main =
  Signal.map view model.signal

-- Utility

-- Convenient for decoding large JSON objects
andMap : J.Decoder (a -> b) -> J.Decoder a -> J.Decoder b
andMap = J.object2 (<|)
