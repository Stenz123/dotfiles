#!/bin/sh

# Default values
steps=500
maxBrigthnessFile="/sys/class/backlight/intel_backlight/max_brightness"
brightnessFile="/sys/class/backlight/intel_backlight/brightness"
minBrightness=400

printHelp() {
  echo "Usage: ./brightness.sh [flags] up|down"
  echo "Flags:"
  echo "	-h: Display this message"
  echo "	-s: Steps (default 1000)"
}



direction=$(echo "$1" | tr '[:upper:]' '[:lower:]')

if [ "$direction" != "up" ] && [ "$direction" != "down" ]; then
  echo "Invalid or missing option"
  printHelp
  exit 1
fi

while getopts "hs:" arg; do
  case $arg in
    h) printHelp; exit 0;;
    s) steps=$OPTARG;;
  esac
done

echo "steps: $steps $direction"

maxBrightness=$(cat $maxBrigthnessFile)
echo $maxBrightness

currentBrigthness=$(cat $brightnessFile)
echo " $currentBrigthness"

if [ "$direction" = "up" ]; then
  newBrightness=$((currentBrigthness + steps))
  if [ "$newBrightness" -gt "$maxBrightness" ]; then
    newBrightness=$maxBrightness
  fi
elif [ "$direction" = "down" ]; then
  newBrightness=$((currentBrigthness - steps))
  if [ "$newBrightness" -lt "$minBrightness" ]; then
    newBrightness=$minBrightness
  fi
fi

brightnessPercent=$(( 100 * newBrightness / maxBrightness ))
echo "percent"
echo $brightnessPercent
dunstify -t 1000 -r 2593 -u normal "󰃞  $brightnessPercent%" -h int:value:$brightnessPercent -h string:hlcolor:#7f7fff
echo $newBrightness | tee $brightnessFile
