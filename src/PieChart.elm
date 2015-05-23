module PieChart where

import Color exposing (..)
import Graphics.Collage exposing (..)
import Graphics.Element exposing (..)
import Mouse
import Window


view : List (Color, Int) -> Element
view pairs =
  let
    colors  = List.map fst pairs
    numbers = List.map snd pairs
  in
    pieChart colors <| List.map toFloat numbers


pieChart : List Color -> List Float -> Element
pieChart colors numbers =
  let fracs = normalize numbers
      offsets = List.scanl (+) 0 fracs
  in
      collage 300 300 <|
        List.concat (List.map3 (pieSlice 100) colors offsets fracs)
        ++ [ filled white (circle 70) ]


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
