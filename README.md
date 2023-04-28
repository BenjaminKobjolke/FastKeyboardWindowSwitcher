# iSwitch

Switch fast between open windows (Windows tool)

## Installation

Download the latest release and start the .exe

## Usage

Use caps-lock to show the window.

When the window is open, just type a few letters matching the desired window's title.

## settings.ini

Rename settings_example.ini to settings.ini.
Then you have adjust the following settings within that file.

### [settings]

#### autoactivateifonlyone

`autoactivateifonlyone=1`
If you type and there is only one matching window then that window will be automatically be activated. No need to press enter.

### [gui]

#### spacing

`spacingHorizontal=10`
The spacing of the iSwitch window from the left your screen in percent.
10 means the window will start 10% from the left the active screen and will also keep the same distance from the right side.

`spacingVertical=10`
The spacing of the iSwitch window from the top your screen in percent.
10 means the window will start 10% from the top the active screen and will also keep the same distance from the bottom side.

#### font

`fontColor=33C4FF`
Text color in hex values or string names like "blue", "yellow", "green"...
Default is 33C4FF.

`fontSize=20`
Font size.
Default is 20.

#### general

`transparency=180`
Window transparency.
Default is 180.
Values between 0 and 255 to indicate the degree of transparency. 0 makes the window invisible while 255 makes it opaque.

## Special configuration files

If you want to ignore some windows
reanme filterlist_example.txt to filterlist.txt and add the windows' titles that you dont want like this "firefox|chrome|winamp"

![plot](./media/demo.gif)

I found the original script here:

> https://www.autohotkey.com/board/topic/30487-iswitchw-cosmetically-enhanced-edition/

_It's a window switcher which shows the matching window titles as you type in your search string incrementally. If only one window is left it is activated immediately (configurable). Otherwise, you can type in more characters (or delete some with backspace) or select between the matching windows using cursor up/down/enter or you can cancel the window with esc._

_You can use any substring of any window. For example, if you want to switch to word then you can type rd and there is a good chance word is selected immediately. Or type "notepad" and select quickly between the notepad windows with the cursor._

_The idea comes from Emacs where it is used to switch between opened files. After a while it gets addictive, it's so efficient. At least it is my experience with emacs._

<hr>

## New features addded:

### Move mouse

Mouse will be moved to the center of the selected window

### Filter list

Array of filters for filtering out titles from the window list.

Rename filterlist_example.txt to filterlist.txt and add the windows you do not want to show up to that list.
Seperate titles with a "|".

### Shortcuts list

List of shortcuts for window titles.
So if you type "wa" it will search for winamp.

Rename shortcuts_example.txt to shortcutslist.txt and add the windows you do not want to show up to that list.
One shortcut per line
Example: wa|winamp

### 24.03.2023 - search min length

settings.ini
settings - searchminlength

Default value = 1

### 27.04.2023 - tray icon support

[trayicons]

Press F1 while the main window is open to switch between listing open windows and tray icons.
Selecting and item and pressing enter will open the right-click menu of that tray icon.
Holding down ctrl before pressing enter will open the left-click menu of that tray icon.
Holding down ctrl and alt before pressing enter will double left-click the tray icon.

### 28.04.2023 tab completion works again

tabComplete=1

This feature was broken for a while. Now it works again.

If enabled possible completions are offered when the same unique
substring is found in the title of more than one window.

For example, the user typed the string "co" and the list is
narrowed to two windows: "Windows Commander" and "Command Prompt".
In this case the "command" substring can be completed automatically,
so the script offers this completion in square brackets which the
user can accept with the TAB key: co[mmand]

# setttins.ini

[trayicons]
alwaystartwithtasks=1
when the iswitch window opens it goes back to showing the tasks instead of the tray icons

#### Description

If the window first opens and you starting typing, the window list will not be updated until this min length is reached.
This improves the performance. Otherwise the input lags and it might miss the first character you type.

# original comments

iswitchw - Incrementally switch between windows using substrings
;
[MODIFIED by ezuk, 3 July 2008, changes noted below. Cosmetics only.]

Required AutoHotkey version: 1.0.25+

When this script is triggered via its hotkey the list of titles of
all visible windows appears. The list can be narrowed quickly to a
particular window by typing a substring of a window title.

When the list is narrowed the desired window can be selected using
the cursor keys and Enter. If the substring matches exactly one
window that window is activated immediately (configurable, see the
"autoactivateifonlyone" variable).

The window selection can be cancelled with Esc.

The switcher window can be moved horizontally with the left/right
arrow keys if it blocks the view of windows under it.

The switcher can also be operated with the mouse, although it is
meant to be used from the keyboard. A mouse click activates the
currently selected window. Mouse users may want to change the
activation key to one of the mouse keys.

For the idea of this script the credit goes to the creators of the
iswitchb package for the Emacs editor
