#!/bin/bash

# Get current Spotify status with play/pause button
#
# by Jason Tokoph (jason@tokoph.net)
#
# Shows current track information from spotify
# 10 second refresh might be a little too quick. Tweak to your liking.

# metadata
# <bitbar.title>Spotify Now Playing</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Jason Tokoph</bitbar.author>
# <bitbar.author.github>jtokoph</bitbar.author.github>
# <bitbar.desc>Display currently playing Spotify song. Play/pause, skip forward, skip backward.</bitbar.desc>
# <bitbar.image>http://i.imgur.com/y1SZwfq.png</bitbar.image>

# BINARIES
# brew install jq
JQ="/usr/local/bin/jq"

# USER VARIABLES

BASEDIR="/Users/di5ko/bitbar"
TEMPFILE="/tmp/search-related.json"

PLAYLISTS=(
	'deephouse'
	'soul'
	'acid jazz'
	'afrobeat'
	'bossa nova'
	'cuban jazz'
	'latin jazz'
	'jazz-funk'
	'soul-jazz'
	'ambient dub'
	'broken beat'
	'blue eyed soul'
	'deep soul'
	'latin soul'
	'blue note'
	'ecm'
)

# DO NOT EDIT BELOW

if [ $(osascript -e 'application "Spotify" is running') = "false" ]; then
  echo "♫"
  echo "---"
  echo "Spotify is not running"
  echo "Launch Spotify | bash=$0 param1=launch terminal=false"
  exit
fi

if [ "$1" = 'launch' ]; then
  osascript -e 'tell application "Spotify" to activate'
  exit
fi
	
if [ "$1" = 'playpause' ]; then
  osascript -e 'tell application "Spotify" to playpause'
  exit
fi

if [ "$1" = 'previous' ]; then
  osascript -e 'tell application "Spotify" to previous track'
  exit
fi

if [ "$1" = 'next' ]; then
  osascript -e 'tell application "Spotify" to set shuffling to true';
  osascript -e 'tell application "Spotify" to set shuffling to false';
  osascript -e 'tell application "Spotify" to next track';
  exit
fi

if [ "$1" = 'nextshuffle' ]; then
  osascript -e 'tell application "Spotify" to set shuffling to false';
  osascript -e 'tell application "Spotify" to set shuffling to true';
  osascript -e 'tell application "Spotify" to next track';
  exit
fi

state=`osascript -e 'tell application "Spotify" to player state as string'`;

if [ $state = "playing" ]; then
  state_icon="▶"
else
  state_icon="❚❚"
fi

track=`osascript -e 'tell application "Spotify" to name of current track as string'`;
artist=`osascript -e 'tell application "Spotify" to artist of current track as string'`;
album=`osascript -e 'tell application "Spotify" to album of current track as string'`;

total="$state_icon $artist - $track"
totalsize=${#total}

if [ "$totalsize" -le "20" ]; then
	echo $state_icon $artist - $track
else
	echo "SPFY: $state_icon"
fi

echo "---"

case "$0" in
  *\ * )
   echo "Your script path | color=#ff0000"
   echo "($0) | color=#ff0000"
   echo "has a space in it, which BitBar does not support. | color=#ff0000"
   echo "Play/Pause/Next/Previous buttons will not work. | color=#ff0000"
  ;;
esac

echo Track: $track "| color=#333333"
echo Artist: $artist "| color=#333333"
echo Album: $album "| color=#333333"

echo '---'

if [ $state = "playing" ]; then
  echo "Pause | bash=$0 param1=playpause terminal=false"
  echo "Previous | bash=$0 param1=previous terminal=false"
  echo "Next | bash=$0 param1=next terminal=false"
  echo "Next (shuffle) | bash=$0 param1=nextshuffle terminal=false"
else
  echo "Play | bash=$0 param1=playpause terminal=false"
fi

echo '---'

echo "Play random track from a similar artist | bash=$0 param1=randomsimilar terminal=false"

echo '---'

SAVEIFS=$IFS
IFS=$'\n'
for PLAYLIST in ${PLAYLISTS[@]}; do
SPLAYLIST=${PLAYLIST// /%20}
echo "Play random $PLAYLIST playlist | bash='$BASEDIR/scripts/spotify.randomplaylist.sh' param1=--playlist param2=$SPLAYLIST terminal=false"
done
IFS=$SAVEIFS

if [ "$1" = 'randomsimilar' ]; then
  TURI=`osascript -e 'tell application "Spotify" to id of current track'`
  TID=`cut -d ":" -f 3 <<< "$TURI"`
  AURI=$(curl -s -X GET "https://api.spotify.com/v1/tracks/$TID" | $JQ '.artists[0] | .uri')
  AID=`cut -d ":" -f 3 <<< "$AURI"`
  AID="${AID//\"}"
  curl -s -X GET "https://api.spotify.com/v1/artists/$AID/related-artists" > $TEMPFILE
  CARTIST=`osascript -e 'tell application "Spotify" to artist of current track as string'`;
  NARTIST=`cat $TEMPFILE | $JQ '.artists[0] | .name'`
  NARTIST="${NARTIST//\"}"
  if [[ $CARTIST =~ .*$CARTIST.* ]]; then
	URI=$(curl -s -X GET "https://api.spotify.com/v1/artists/$AID/related-artists" | $JQ '.artists[1] | .uri')
	osascript -e "tell application \"Spotify\" to play track ${URI}";
	exit
  else
	URI=$(cat $TEMPFILE | $JQ '.artists[0] | .uri')
	osascript -e "tell application \"Spotify\" to play track ${URI}";
	exit
  fi
fi