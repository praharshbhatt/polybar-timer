# polybar-timer

A Timer module for [Polybar](https://github.com/jaagr/polybar)

## Dependencies
* [rofi](https://github.com/DaveDavenport/rofi)

## Screenshots
![Timer Creation](screenshots/1.gif)
![Timer End](screenshots/2.gif)

## Usage



1. Place the given script in the `~/.config/polybar/scripts` folder. If you want to place it in another folder, make sure to update the line:
```bash
TIMER_FILE="$HOME/.config/polybar/scripts/timers.json"
```
to the path of your script's parent folder.


2. Use the following config in your polybar `config`:

```
[module/timer]
type = custom/script
exec = ~/.config/polybar/scripts/polybar-timer.sh --status
interval = 10
click-left = ~/.config/polybar/scripts/polybar-timer.sh --menu
```
Again, do ensure to change the path above if you decide to place this script anywhere else.

