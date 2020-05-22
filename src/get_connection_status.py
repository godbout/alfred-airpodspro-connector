#!/usr/bin/env python

import os
import re
import json
import sys

mac = os.getenv('AIRPODS_MAC')

if mac == None or mac == "":
    menu = {
        "items": [
            {
                "uid": 0,
                "type": "default",
                "title": "Your setup isn't completet yet.",
                "subtitle": "Configure your AirPods Pro device to get started.",
                "arg": "unconfigured",
            }
        ]
    }
    print(json.dumps(menu))
    sys.exit()

devices = os.popen('/bin/bash -c "system_profiler SPBluetoothDataType"').read()

connectedRegex = r"(Address: " + mac.upper() + "(.*\n)*?.*Connected: )(Yes|No)"
statusMatch = re.finditer(connectedRegex, devices, re.MULTILINE)

status = ""

for matchNum, match in enumerate(statusMatch):
    if match.group() != '':
        if match.group(3) == "Yes":
            status = "connected"
        else:
            status = "disconnected"

menu = {
    "items": [
        {
            "uid": 0,
            "type": "default",
            "title": "Disconnect AirPods Pro" if status == "connected" else "Connect AirPods Pro",
            "subtitle": "Status: " + status,
            "arg": status,
        }
    ]
}

print(json.dumps(menu))
