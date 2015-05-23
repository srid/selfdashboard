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
  in
      collage 400 300 <|
        List.concat (List.map3 (pieSlice 100) colors offsets fracs)
        ++ [ filled white (circle 70) ]
        ++ (legend segments)

legend : List Segment -> List Form
legend segments =
  let
    size       = List.length segments
    xPositions = List.map toFloat <| List.repeat size 130
    yPositions = List.map toFloat <| List.map ((*) 30) [1..size]
    positions  = zip xPositions yPositions
  in
    List.concatMap (legendItem 50) <| zip segments positions

legendItem : Float -> (Segment, (Float, Float)) -> List Form
legendItem offset ({label, colr}, position) =
  let
    box =
      square 30
        |> filled colr
        |> move position
    lbl =
      show label
        |> toForm
        |> move (offset + fst position, snd position)
  in
    [box, lbl]


pieSlice : Float -> Color -> Float -> Float -> List Form
pieSlice radius colr offset angle =
  let makePoint t = fromPolar (radius, degrees (360 * offset + t))
  in
      [ filled colr <| polygon ((0,0) :: List.map makePoint[ 0 .. 360 * angle ])
      , toForm (asPercent angle)
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
