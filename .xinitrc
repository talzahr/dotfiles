#!/bin/sh
#xrdb -merge ~/.Xresources
# start some nice programs

#if [ -d /etc/X11/xinit/xinitrc.d ] ; then
# for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
#  [ -x "$f" ] && . "$f"
# done
# unset f
#fi

#exec startplasma-x11

#OpenBox
#xrandr -s 1920x1080 --rate 75
#exec openbox-session
xset -dpms
#exec picom; exec feh --bg-scale ~/Downloads/ancient-wizard-library-chair-spell.jpg; exec tint2 -c ~/.config/tint2/tint2rc

#exec i3

###For dwm below
setxkbmap -option caps:none
feh --bg-fill $HOME/Pictures/backgrounds/lanterns1920.png; exec dwm; dwmstart &
