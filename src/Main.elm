-- A program to display how one is feeling overall in the last 2 days.
-- Data is fetched from Heroku Dataclips.

import Color
import Signal
import Signal exposing (Signal, Mailbox)
import Task
import Task exposing (Task, andThen)
import Json.Decode  as J
import Json.Decode exposing ((:=))
import Debug exposing (log)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)

import Util exposing (zip, zip3)
import PieChart


-- View

port title : String
port title =
  "Srid's dashboard"

view : Maybe DataClip -> Html
view maybeModel =
  div [] [ h1 [] [ text "How is Srid feeling in the last 2 days?" ]
         , case maybeModel of
            Nothing       -> em [] [ text "Loading..." ]
            Just dataClip -> viewDataClip dataClip
         , p [] [ a [ href "https://github.com/srid/selfdashboard" ]
                    [ text "More information"]
                ]
         ]

viewDataClip : DataClip -> Html
viewDataClip =
  fromElement << PieChart.view << toSegments

-- Dataclip

type alias DataClip =
  { fields : List String
  , types  : List Int
  , values : List (String, Int)
  }

toSegments : DataClip -> List PieChart.Segment
toSegments dataClip =
  let
    fieldToColor field =
      case field of
        "great"    -> Color.green
        "good"     -> Color.blue
        "meh"      -> Color.grey
        "bad"      -> Color.orange
        "terrible" -> Color.red
    numbers      = List.map (toFloat << snd) dataClip.values
    labels       = List.map fst dataClip.values
    colors       = List.map fieldToColor labels
    in
        List.map makeSegment <| zip3 labels colors numbers

makeSegment : (String, Color.Color, Float) -> PieChart.Segment
makeSegment (label, colr, value) =
  { label=label, colr=colr, value=value }

-- JSON decoder

decodeDataClip : J.Decoder DataClip
decodeDataClip = DataClip
  `J.map`  ("fields"   := J.list J.string)
  `andMap` ("types"    := J.list J.int)
  `andMap` ("values"   := J.list decodePair)

decodePair : J.Decoder (String, Int)
decodePair = J.tuple2 (,) J.string J.int

-- Fetching

dataClipUrl : String
dataClipUrl = "/api"

fetch : Task Http.Error DataClip
fetch =
  Http.get decodeDataClip dataClipUrl

-- Elm machinary

mainTask : Task Http.Error ()
mainTask =
  withErrorLogging
    <| fetch
      `andThen` (Just >> Signal.send model.address)

model : Mailbox (Maybe DataClip)
model =
  Signal.mailbox Nothing

port mainPort : Signal (Task Http.Error ())
port mainPort =
  Signal.mailbox mainTask |> .signal

main : Signal Html
main =
  Signal.map view model.signal

withErrorLogging : Task x a -> Task x a
withErrorLogging task =
  Task.mapError (log "[TASK ERROR]") task

-- Utility

-- Convenient for decoding large JSON objects
andMap : J.Decoder (a -> b) -> J.Decoder a -> J.Decoder b
andMap = J.object2 (<|)
