module SideBar.Controls where

import Color
import FontAwesome
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (..)
import String

import Debugger.Active as Active
import Model
import SideBar.Button as Button
import Utils.Style exposing ((=>))


styles : String
styles = """

.controls {
  display: -webkit-flex;
  -webkit-flex-direction: row;
  -webkit-justify-content: space-between;
  -webkit-align-items: center;

  -webkit-flex: 0 0 auto;
  -moz-flex: 0 0 auto;
  -ms-flex: 0 0 auto;
  flex: 0 0 auto;

  padding: 12px;
}

.left-sidebar-header {
  display: flex;

  -webkit-flex: 0 0 auto;
  -moz-flex: 0 0 auto;
  -ms-flex: 0 0 auto;
  flex: 0 0 auto;

  background-color: rgb(46, 46, 46);
}

.scrubber {
  margin: 0;
  width: 100%;
}

.scrubber-container {
  position: relative;

  -webkit-flex: 1 0 auto;
  -moz-flex: 1 0 auto;
  -ms-flex: 1 0 auto;
  flex: 1 0 auto;

  margin: auto 0;
  padding-right: 16px;
}

.play-pause-button {
  padding: 8px;
  background-color: rgb(29, 134, 199);
  border-radius: 16px;
  width: 32px;
  height: 32px;

  cursor: pointer;

  transition: all 0.3s ease 0s;
}

.play-pause-button:hover {
  background-color: rgb(4, 109, 174);
}

.play-pause-button svg {
  position: relative;
  top: 4px;
  left: 5px;
}

"""


-- VIEW

view : Signal.Address Model.Message -> Model.Model -> Active.Model -> Html
view addr state activeState =
  let
    buttonContainer =
      div
        [ class "controls" ]
        [ playPauseButton
            (Signal.forwardTo addr Model.PlayPauseButtonAction)
            (not <| Active.isPlaying activeState)
            state.playPauseButtonState
        ]

    sliderContainer =
      div
        [ class "scrubber-container"]
        [ scrubSlider (Signal.forwardTo addr Model.ServiceCommand) activeState
        ]
  in
    div
      [ class "left-sidebar-header" ]
      [ buttonContainer
      , sliderContainer
      ]


playPauseButton : Signal.Address (Button.Message Active.Command) -> Bool -> Button.Model -> Html
playPauseButton addr isPlay state =
  let
    icon =
      if isPlay then
        FontAwesome.play Color.white 24
      else
        FontAwesome.pause Color.white 24

    render state =
      icon
  in
    Button.view
      addr
      (if isPlay then Active.Play else Active.Pause)
      state
      render


scrubSlider : Signal.Address Active.Command -> Active.Model -> Html
scrubSlider addr activeState =
  let
    numFrames =
      activeState.numFrames

    curFrame =
      Active.curFrameIdx activeState
  in
    input
      [ type' "range"
      , class "scrubber"
      , Attr.min "0"
      , Attr.max <| toString <| numFrames - 1
      , Attr.value <| toString <| curFrame
      , on "input"
          (at ["target","value"] (customDecoder string String.toInt))
          (\idx ->
            Signal.message
              addr
              (Active.ScrubTo idx))
      ]
      []

