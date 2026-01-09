#!/bin/zsh

SYSTEM_PROFILER=$(system_profiler SPBluetoothDataType 2>/dev/null)
HEADPHONES=$(grep -B9 "Minor Type: Headphones" <<< "${SYSTEM_PROFILER}")

print_device() {
    if [ "$device" != "" ]; then
        MAC_ADDRESS=$(echo "${device}" | awk '/Address/{print $2}')
        NAME=$(echo "${device}" | awk '/Address/ {print prev} {prev=$0}')

        if [[ $(arch) == 'arm64' ]]; then
          CONNECTED=$(resources/binaries/blueutil_arm64 --is-connected ${MAC_ADDRESS})
        else
          CONNECTED=$(resources/binaries/blueutil_i386 --is-connected ${MAC_ADDRESS})
        fi

        if [[ "${CONNECTED}" == 1 ]]; then
          # disconnect doesn't work on Monterey if we don't force notify LMAO
          echo "<item> <title>disconnect ${NAME%?}</title> <arg>--disconnect ${MAC_ADDRESS//:/-}</arg> </item>"
        else
          echo "<item> <title>connect ${NAME%?}</title> <arg>--connect ${MAC_ADDRESS//:/-}</arg> </item>"
        fi
    fi
}

COUNT=$(echo $HEADPHONES | grep -c "Minor Type: Headphones")

if [[ "$COUNT" != "0"  ]]; then

    echo "<?xml version='1.0' encoding='utf-8'?> <items>" # use XML as it will be easier to print logs to the output into alfred with echo

    nl=$'\n'
    device=""

    HEADPHONES="$HEADPHONES$nl--" # append a separator to the end

    ## split HEADPHONES into devices

    echo "${HEADPHONES}" | while read -r line
    do
        if [ "$device" = "" ]
            then
            device="$line"
        elif [ "$line" = "--" ]
            then
            print_device # print device in XML
            device=""
        else
            device="$device$nl$line" # append more lines to the device
        fi
    done

    echo "</items>"

else
cat << EOB
    {"items": [
        {
            "uid": "connector",
            "title": "no headphones paired",
        }
    ]}
EOB
fi
