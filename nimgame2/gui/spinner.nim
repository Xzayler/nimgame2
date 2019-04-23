# nimgame2/gui/spinner.nim
# Copyright (c) 2016-2019 Vladimir Arabadzhi (Vladar)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# vladar4@gmail.com
# https://github.com/Vladar4


##  ``GuiSpinner``
##  is a complex widget that consist of TextInput and two Buttons.
##
##  Buttons increase or decrease the value (``more`` or ``less`` buttons
##  accordingly). Direct input (through TextInput) is also available.
##
##  Buttons' positioning (in realtion to the TextInput widget)
##  is determined by ``style`` property.
##


import
  math, strutils,
  ../font,
  ../graphic,
  ../input,
  ../textfield,
  ../textgraphic,
  ../types,
  button,
  textinput,
  widget


type
  GuiSpinnerStyle* {.pure.} = enum
    leftAndRight,
    left,
    right,
    topAndBottom,
    top,
    bottom

  # Private
  GuiSpinnerButton = ref object of GuiButton
    target*: GuiSpinner

  GuiSpinner* = ref object of GuiTextInput
    # Private
    fMore, fLess: GuiButton
    fStyle*: GuiSpinnerStyle
    # Public
    min*, max*, value*, step*: float
    precision*: range[0..32]  ## value format precision (defaults to 0)
    unit*: string             ## value format unit (defaults to " ")
    decimalSep*: char       ## value format decimal separator (defaults to '.')
    op*: proc(v: float): float  ## operation to perform on inputted values \
                                ## (round, floor, ceil, etc.)
    border*: Dim                ## empty space between the elements


template format*(spinner: GuiSpinner): string =
  formatEng(
      spinner.value,
      precision = spinner.precision,
      decimalSep = spinner.decimalSep)


proc initGuiSpinnerButton(button: GuiSpinnerButton,
                          graphic: Graphic,
                          image: Graphic = nil,
                          circle: bool = false,
                          target: GuiSpinner = nil) =
  button.initGuiButton(graphic, image, circle)
  button.target = target


proc newGuiSpinnerButton(graphic: Graphic,
                         image: Graphic = nil,
                         circle: bool = false,
                         target: GuiSpinner = nil): GuiSpinnerButton =
  result = new GuiSpinnerButton
  result.initGuiSpinnerButton(graphic, image, circle, target)


proc clickGuiSpinnerMore*(widget: GuiWidget, mb: MouseButton) =
  let target = GuiSpinnerButton(widget).target
  target.value += target.step
  if target.value > target.max:
    target.value = target.max
  target.text.text = target.format & target.unit


proc clickGuiSpinnerLess*(widget: GuiWidget, mb: MouseButton) =
  let target = GuiSpinnerButton(widget).target
  target.value -= target.step
  if target.value < target.min:
    target.value = target.min
  target.text.text = target.format & target.unit


proc style*(spinner: GuiSpinner): GuiSpinnerStyle {.inline.} =
  spinner.fStyle


proc `style=`*(spinner: GuiSpinner, val: GuiSpinnerStyle) =
  let
    text = spinner.sprite.dim
    middle = text / 2
    more = spinner.fMore.sprite.dim
    less = spinner.fLess.sprite.dim
    border = spinner.border

  case val:
  of GuiSpinnerStyle.leftAndRight:
    spinner.fMore.pos = ( text.w + border.w,
                          middle.h - more.h div 2)
    spinner.fLess.pos = (-less.w - border.w,
                          middle.h - more.h div 2)
  of GuiSpinnerStyle.left:
    spinner.fMore.pos = (-more.w - border.w,
                          middle.h - more.h - floor(border.h.float / 2).int)
    spinner.fLess.pos = (-less.w - border.w,
                          middle.h + ceil(border.h.float / 2).int)
  of GuiSpinnerStyle.right:
    spinner.fMore.pos = (text.w + border.w,
                         middle.h - more.h - floor(border.h.float / 2).int)
    spinner.fLess.pos = (text.w + border.w,
                         middle.h + ceil(border.h.float / 2).int)
  of GuiSpinnerStyle.topAndBottom:
    spinner.fMore.pos = ( middle.w - more.w div 2,
                         -more.h - border.h)
    spinner.fLess.pos = ( middle.w - less.w div 2,
                          text.h + border.h)
  of GuiSpinnerStyle.top:
    spinner.fMore.pos = ( middle.w + ceil(border.w.float / 2).int,
                         -more.h - border.h)
    spinner.fLess.pos = ( middle.w - less.w - floor(border.w.float / 2).int,
                         -less.h - border.h)
  of GuiSpinnerStyle.bottom:
    spinner.fMore.pos = (middle.w + ceil(border.w.float / 2).int,
                         text.h + border.h)
    spinner.fLess.pos = (middle.w - less.w - floor(border.w.float / 2).int,
                         text.h + border.h)


proc initGuiSpinner*(
    spinner: GuiSpinner,
    text, button, more, less: Graphic, font: Font,
    circle: bool = false, border: Dim = (0, 0),
    style: GuiSpinnerStyle = GuiSpinnerStyle.leftAndRight) =
  ##  GuiSpinner initialization.
  ##
  ##  ``font``  text font. Should not be `nil`.
  ##
  ##  ``button``  button graphic (see ``GuiButton``)
  ##
  ##  ``more``, ``less``  images for spinner buttons
  ##
  ##  ``text``  graphic for the text background. Might be `nil`.
  ##
  spinner.initGuiTextInput(text, font)
  spinner.min = 0
  spinner.max = 100
  spinner.value = 0
  spinner.step = 1
  spinner.precision = 0
  spinner.unit = " "
  spinner.decimalSep = '.'
  spinner.border = border

  spinner.text.text = "0"

  spinner.fMore = newGuiSpinnerButton(button, more, circle, spinner)
  spinner.fMore.parent = spinner
  spinner.fMore.actions.add clickGuiSpinnerMore
  spinner.fLess = newGuiSpinnerButton(button, less, circle, spinner)
  spinner.fLess.parent = spinner
  spinner.fLess.actions.add clickGuiSpinnerLess

  spinner.graphic = text

  spinner.style = style


proc newGuiSpinner*(
  text, button, more, less: Graphic, font: Font,
  circle: bool = false, border: Dim = (0, 0),
  style: GuiSpinnerStyle = GuiSpinnerStyle.leftAndRight): GuiSpinner =
  result = new GuiSpinner
  result.initGuiSpinner(text, button, more, less, font, circle, border, style)


proc enterGuiSpinner*(spinner: GuiSpinner) =
  if spinner.toggled:
    spinner.text.text = ""
    spinner.fLess.disable()
    spinner.fMore.disable()
  spinner.enterGuiTextInput()


method enter*(spinner: GuiSpinner) =
  spinner.enterGuiSpinner()


proc leaveGuiSpinner*(spinner: GuiSpinner) =
  spinner.leaveGuiTextInput()
  spinner.value = try:
    if spinner.op == nil:
      parseFloat(spinner.text.text)
    else:
      spinner.op(parseFloat(spinner.text.text))
  except ValueError:
    spinner.value
  spinner.value = spinner.value.clamp(spinner.min, spinner.max)
  spinner.text.text = spinner.format & spinner.unit
  spinner.fLess.enable()
  spinner.fMore.enable()


method leave*(spinner: GuiSpinner) =
  spinner.leaveGuiSpinner()


proc clickGuiSpinner*(spinner: GuiSpinner, mb: MouseButton) =
  spinner.clickGuiTextInput(mb)


method click*(spinner: GuiSpinner, mb: MouseButton) =
  spinner.clickGuiSpinner(mb)


proc eventGuiSpinner*(spinner: GuiSpinner, e: Event) =
  spinner.eventGuiTextInput(e)
  spinner.fMore.eventGuiButton(e)
  spinner.fLess.eventGuiButton(e)


method event*(spinner: GuiSpinner, e: Event) =
  spinner.eventGuiSpinner(e)


proc renderGuiSpinner*(spinner: GuiSpinner) =
  # text
  if not spinner.toggled:
    spinner.text.text = spinner.format & spinner.unit
  spinner.renderGuiTextInput()
  # buttons
  spinner.fMore.render()
  spinner.fLess.render()


method render*(spinner: GuiSpinner) =
  spinner.renderGuiSpinner()

