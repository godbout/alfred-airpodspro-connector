SYSTEM_PROFILER=$(system_profiler SPBluetoothDataType 2>/dev/null)

MAC_ADDRESS=$(grep -B8 "Minor Type: Headphones" <<< "${SYSTEM_PROFILER}" | awk '/Address/{ lastline = $2 } END { print lastline }')

if [[ $(arch) == 'arm64' ]]; then
  CONNECTED=$(resources/binaries/blueutil_arm64 --is-connected ${MAC_ADDRESS})
else
  CONNECTED=$(resources/binaries/blueutil_i386 --is-connected ${MAC_ADDRESS})
fi

NAME=$(grep -B9 "Minor Type: Headphones" <<< "${SYSTEM_PROFILER}" | awk '/AirPods/{ print }' | sed -e 's/^ *//' -e 's/://')

if [[ "${CONNECTED}" == 1 ]]; then
  status="disconnect ${NAME}"
  # disconnect doesn't work on Monterey if we don't force notify LMAO
  arg="--disconnect ${MAC_ADDRESS//:/-}"
else
  status="connect ${NAME}"
  arg="--connect ${MAC_ADDRESS//:/-}"
fi

cat << EOB
{"items": [
    {
        "uid": "connector",
        "type": "default",
        "title": "$status",
        "arg": "$arg",
    }
]}
EOB
