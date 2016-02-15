#!/bin/bash

# BINARIES
JQ="/usr/local/bin/jq"

if [ "$1" != "--playlist" ]; then
  exit 1
else
  if [ "$2" = "" ]; then
    exit 1
  else
    TOTAL=$(curl -s -X GET "https://api.spotify.com/v1/search?q=$2&type=playlist&limit=1&market=NL" | $JQ '.playlists.total')
    OFFSET=$(jot -r 1 0 $TOTAL)
    URI=$(curl -s -X GET "https://api.spotify.com/v1/search?q=$2&type=playlist&offset=$OFFSET&limit=1&market=NL" | $JQ '.playlists .items[] | .uri')
    osascript -e "tell application \"Spotify\" to play track ${URI}"
    exit
  fi
fi
