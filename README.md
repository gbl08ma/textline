Textline
==========

This is a [Minetest](http://www.minetest.net/) mod that adds a text screen that is three blocks wide and is controlled with [Digilines](https://github.com/minetest-mods/digilines/). It works very similarly to the LCD screen that comes with Digilines, but is meant to be readable from farther away.

![Screenshot](https://raw.githubusercontent.com/gbl08ma/textline/master/screenshot.png?raw=true)

## Features

* Dimensions: 3x1
* Always stands vertically (can't be floor- or ceiling-mounted)
* Four lines of orange text with 27 characters each, on a black background
* Explicit line breaks with the newline character (\n) or the pipe (|) character. No text wrapping, for maximum control of the output.
* Memory: the display "remembers" what it was displaying across server shutdowns. No need to constantly refresh its contents.
* Optimized for frequent refreshes: its contents can change every second without excessive object generation.

## Installing

Just install it like any other Minetest mod.

1. [Download](https://github.com/gbl08ma/textline/archive/master.zip)

1. Extract the ZIP into the Minetest mods folder (usually `mods`);

1. Rename the `textline-master` folder to `textline`;

1. This mod depends on Digilines, make sure you have it installed;

1. In Minetest, enable the mod in the world settings.

## Usage

A display consists of three separate nodes that must be placed individually. The center node is responsible for displaying the text it receives through Digilines; the two blocks to the sides make the rest of the background for the display.

The background node appears in the inventory as an orange square with "BKG" written on it. The center node appears as "TXT".

Digilines should be connected to the "TXT" block. You can configure its channel by clicking with the place/use button on them (default: right-click). Then you can just use it as a standard Digilines receiver. For example, for a screen running on channel `test`, you could execute the following code on a connected LuaController:

`digiline_send("test", "This is a test\nThis is the second line\nThird line\nFourth line")`

## License

See LICENSE.txt

