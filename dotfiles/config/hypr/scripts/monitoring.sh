#!/bin/bash

sleepTimer=${1:-5}  # Default to 5 seconds if no argument is provided
COLOR_CONFIG_FILE="$HOME/.config/hypr/colors.conf"

max_charge=$(cat /sys/class/power_supply/BAT0/charge_full)
charge_alarm_threshold=$(expr $max_charge / 100 \* 15)


get_color() {
    grep -Po "(?<=${1}= )[\da-fA-F]+" "$COLOR_CONFIG_FILE"
}

COLOR_PRIMARY=$(get_color "color_primary")
COLOR_TERTIARY=$(get_color "color_tertiary")
COLOR_LOW_BATTERY=$(get_color "color_low_battery")
COLOR_LOW_BATTERY_CHARGING=$(get_color "color_low_battery_charging")
COLOR_CHARGING=$(get_color "color_charging")

updateCharging() {
    curr_charge=$(cat /sys/class/power_supply/BAT0/charge_now)
    charging_status=$(cat /sys/class/power_supply/BAT0/status)
    if test $curr_charge -lt $charge_alarm_threshold; then
	if [ "$charging_status" = "Charging" ]; then
            hyprctl keyword general:col.active_border "rgba(${COLOR_LOW_BATTERY_CHARGING})"
	else
            hyprctl keyword general:col.active_border "rgba(${COLOR_LOW_BATTERY})"
	fi
    else
	if [ "$charging_status" = "Charging" ]; then
            hyprctl keyword general:col.active_border "rgba(${COLOR_CHARGING})"
	else
            hyprctl keyword general:col.active_border "rgba(${COLOR_PRIMARY})"
	fi
    fi
}

while true; do
    updateCharging "$curr_charge"
    sleep "$sleepTimer"
done

