#!/bin/zsh

print_device() {
    if [ "$headphone" != "" ]; then
        MAC_ADDRESS=$(echo "${headphone}" | awk '/Address/{print $2}')
        NAME=$(echo "${headphone}" | awk '/Address/ {print prev} {prev=$0}')

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

WHOLE_BLUETOOTH_DATA=$(system_profiler SPBluetoothDataType 2>/dev/null)
HEADPHONES=$(grep -B9 "Minor Type: Headphones" <<< "${WHOLE_BLUETOOTH_DATA}")
HEADPHONES_COUNT=$(echo $HEADPHONES | grep -c "Minor Type: Headphones")

if [[ "$HEADPHONES_COUNT" != "0"  ]]; then
    echo "<?xml version='1.0' encoding='utf-8'?> <items>" # use XML as it will be easier to print logs to the output into alfred with echo

    nl=$'\n'
    device=""

    HEADPHONES="$HEADPHONES$nl--" # append a separator to the end

    ## split HEADPHONES into devices
    echo "${HEADPHONES}" | while read -r line
    do
        if [ "$headphone" = "" ]
            then
            headphone="$line"
        elif [ "$line" = "--" ]
            then
            print_device # print device in XML
            headphone=""
        else
            headphone="$headphone$nl$line" # append more lines to the device
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
