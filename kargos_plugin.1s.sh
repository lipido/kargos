#!/bin/bash
echo "$(date)"
echo "---"
echo "Launch Gimp | bash=/usr/bin/gimp"
echo "OS: $(uname)"
echo "Go to <i>Google</i> | href=http://www.google.com size=4 iconName=dialog-ok" 
TOP_OUTPUT=$(top -b -n 1 | head -n 20 | awk 1 ORS="\\\\n")
echo "$TOP_OUTPUT | font=monospace iconName=document-open"
