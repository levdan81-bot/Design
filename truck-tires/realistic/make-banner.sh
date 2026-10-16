#!/usr/bin/env bash
# Превращает любой исходный ролик (сток или AI-генерация) в баннер:
# 2400×600 (4:1), бесшовный цикл через кроссфейд, WebM (VP9) + MP4 (H.264), каждый ≤ 3 МБ.
#
#   ./make-banner.sh input.mp4 [start_sec=0] [duration_sec=7] [crop_y=0.5] [out_name=truck-tires-real]
#
#   start_sec    — откуда брать фрагмент в исходнике
#   duration_sec — длина итогового цикла (≤ 8)
#   crop_y       — какую полосу 4:1 оставить по вертикали: 0 = верх, 0.5 = центр, 1 = низ
set -euo pipefail
IN=${1:?input video}; SS=${2:-0}; D=${3:-7}; CY=${4:-0.5}; OUT=${5:-truck-tires-real}
X=0.8          # длительность кроссфейда на стыке цикла, с
FPS=30
LIMIT=$((3 * 1024 * 1024))
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

VF="fps=$FPS,crop=iw:'min(ih,iw/4)':0:'(ih-min(ih,iw/4))*$CY',scale=2400:600:flags=lanczos,setsar=1,format=yuv420p"
FC="[0:v]$VF,split[a][b];[a]trim=$X:$(echo "$D+$X" | bc),setpts=PTS-STARTPTS[main];[b]trim=0:$X,setpts=PTS-STARTPTS[head];[main][head]xfade=transition=fade:duration=$X:offset=$(echo "$D-$X" | bc)[v]"

ffmpeg -loglevel error -y -ss "$SS" -t "$(echo "$D+$X+0.5" | bc)" -i "$IN" -filter_complex "$FC" -map '[v]' -an \
  -c:v ffv1 "$TMP/loop.mkv"

enc_webm() { # $1 = kbit/s
  (cd "$TMP" && ffmpeg -loglevel error -y -i loop.mkv -c:v libvpx-vp9 -b:v ${1}k -maxrate $(( $1 * 5 / 4 ))k -row-mt 1 -pass 1 -an -f null /dev/null &&
   ffmpeg -loglevel error -y -i loop.mkv -c:v libvpx-vp9 -b:v ${1}k -maxrate $(( $1 * 5 / 4 ))k -row-mt 1 -cpu-used 1 -pass 2 -an "$OLDPWD/$OUT.webm")
}
enc_mp4() {
  ffmpeg -loglevel error -y -i "$TMP/loop.mkv" -c:v libx264 -preset slow -b:v ${1}k -maxrate $(( $1 * 5 / 4 ))k \
    -bufsize $(( $1 * 2 ))k -profile:v high -pix_fmt yuv420p -movflags +faststart -an "$OUT.mp4"
}
# битрейт с запасом под 3 МБ, при перелёте — снижаем
for f in webm mp4; do
  KB=$(echo "2.7 * 8 * 1024 / $D" | bc)
  while :; do
    enc_$f "$KB"
    S=$(stat -c %s "$OUT.$f")
    [ "$S" -le "$LIMIT" ] && break
    KB=$(( KB * 85 / 100 ))
  done
  echo "$OUT.$f: $((S / 1024)) КБ @ ${KB} кбит/с"
done
ffmpeg -loglevel error -y -i "$OUT.mp4" -frames:v 1 -q:v 3 "$OUT-poster.jpg"
