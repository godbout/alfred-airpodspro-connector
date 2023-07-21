SYSTEM_PROFILER=$(system_profiler SPBluetoothDataType 2>/dev/null)

MAC_ADDRESS=$(grep -B8 "Minor Type: Headphones" <<< "${SYSTEM_PROFILER}" | awk '/Address/{ lastline = $2 } END { print lastline }')
CONNECTED=$(grep -A10 "${MAC_ADDRESS}" <<< "${SYSTEM_PROFILER}" | awk '/Services:/{print 1}')
NAME=$(grep -B9 "Minor Type: Headphones" <<< "${SYSTEM_PROFILER}" | awk '/AirPods/{ print }' | sed -e 's/^ *//' -e 's/://')

if [[ "${CONNECTED}" ]]; then
  status="disconnect ${NAME}"
  # disconnect doesn't work on Monterey if we don't force notify LMAO
  arg="--disconnect ${MAC_ADDRESS//:/-} --notify"
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
