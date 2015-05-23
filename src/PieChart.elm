module PieChart where

import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Mouse
import Window

import Util exposing (zip)

type alias Segment =
  { label   : String
  , colr    : Color
  , value   : Float
  }

view : List Segment -> Element
view segments =
  pieChart segments


pieChart : List Segment -> Element
pieChart segments =
  let numbers = List.map .value segments
      colors  = List.map .colr segments
      fracs = normalize numbers
      offsets = List.scanl (+) 0 fracs
      labels  = List.map .label segments
  in
      collage 400 300 <|
        List.concat (List.map4 (pieSlice 100) colors offsets fracs labels)
        ++ [ filled white (circle 70) ]

pieSlice : Float -> Color -> Float -> Float -> String -> List Form
pieSlice radius colr offset angle label =
  let makePoint t = fromPolar (radius, degrees (360 * offset + t))
  in
      [ filled colr <| polygon ((0,0) :: List.map makePoint[ 0 .. 360 * angle ])
      , toForm (show label)
          |> move (fromPolar (radius*1.25, turns (offset + angle/2)))
      ]


asPercent : Float -> Element
asPercent fraction =
  show (toString (toFloat (truncate (fraction * 100))) ++ "%")


normalize : List Float -> List Float
normalize xs =
  let total = List.sum xs
  in
      List.map (\x -> x/total) xs
