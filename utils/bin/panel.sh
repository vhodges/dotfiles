#!/bin/sh
#
# z3bra - (c) wtfpl 2014
# Fetch infos on your computer, and print them to stdout every second.

clock() {
    date "+%a %d %b, %H:%M"
}

battery() {
    BATC=/sys/class/power_supply/BAT1/capacity
    BATS=/sys/class/power_supply/BAT1/status

    test "`cat $BATS`" = "Charging" && echo -n '+' || echo -n '-'

    sed -n p $BATC
}

volume() {
    amixer get Master | sed -n 'N;s/^.*\[\([0-9]\+%\).*$/\1/p'
}

cpuload() {
    LINE=`ps -eo pcpu |grep -vE '^\s*(0.0|%CPU)' |sed -n '1h;$!H;$g;s/\n/ +/gp'`
    bc <<< $LINE
}

cputemp() {
    t=`cat /sys/class/thermal/thermal_zone0/temp`
    expr $t / 1000
}

memused() {
    read t a <<< `grep -E 'Mem(Total|Available)' /proc/meminfo |awk '{print $2}'`
    bc -l <<< "($t - $a) / (1024*1024)" | cut -d. -f1
}

network() {
    read lo int1 int2 <<< `ip link | sed -n 's/^[0-9]: \(.*\):.*$/\1/p'`
    if iwconfig $int1 >/dev/null 2>&1; then
        wifi=$int1
        eth0=$int2
    else
        wifi=$int2
        eth0=$int1
    fi
    ip link show $eth0 | grep 'state UP' >/dev/null && int=$eth0 ||int=$wifi

    #int=eth0

    ping -c 1 8.8.8.8 >/dev/null 2>&1 && 
        echo "$int connected" || echo "$int disconnected"
}

desktopname() {
    cur=`xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}'`
    tot=`xprop -root _NET_NUMBER_OF_DESKTOPS | awk '{print $3}'`

    wsindex=$(expr $cur + 1)
    
    name=`xprop -root _NET_DESKTOP_NAMES | awk '{$1 = ""; $2 = ""; print $0}' | cut -d , -f $wsindex | sed -e 's/"//' -e 's/"$//'`

    echo " $name"
}

nowplaying() {
    cur=`mpc current`
    # this line allow to choose whether the output will scroll or not
    test "$1" = "scroll" && PARSER='skroll -n20 -d0.5 -r' || PARSER='cat'
    test -n "$cur" && $PARSER <<< $cur || echo "- stopped -"
}

lockscreen () {
    echo "i3lock -c 202020"
}

volumecontrol () {
    echo "pavucontrol &"
}


# This loop will fill a buffer with our infos, and output it to stdout.
while :; do
    buf=""

    buf="${buf}%{l}%{O5}%{F#51c4d4}%{B#151515} "
    buf="${buf}%{F#51c4d4}%{B#151515} $(desktopname)"
    
    buf="${buf}%{c}%{F#51c4d4}%{B#151515}   $(clock) %{F-}%{B-}"

    buf="${buf}%{r}%{O15}%{F#51c4d4}%{B#151515}   $(cpuload)% %{F-}%{B-}"
    buf="${buf}%{O15}%{F#51c4d4}%{B#151515}   $(cputemp)c %{F-}%{B-}"
    buf="${buf}%{O15}%{F#51c4d4}%{B#151515}    $(memused)G %{F-}%{B-}"
    buf="${buf}%{O15}%{F#51c4d4}%{B#151515} %{A:$(volumecontrol):} $(volume) %{A} %{F-}%{B-}"
    buf="${buf}%{O40}%{F#51c4d4}%{B#151515} %{A:$(lockscreen):} Lock %{A} %{F-}%{B-}"
    #buf="${buf} MPD: $(nowplaying)"
     
    buf="${buf}%{O10}%{F#51c4d4}%{B#151515} "
    echo $buf
    # use `nowplaying scroll` to get a scrolling output!
    sleep 1 # The HUD will be updated every second
done

