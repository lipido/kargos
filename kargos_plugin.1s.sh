#!/bin/bash
echo "$(date)"
echo "---"
echo "Gimp2 | bash=/usr/bin/gimp"
echo "Mi kernel es $(uname -a)"
echo "Go to <i>Google</i><br><font size='2'>small subtext</font> | href=http://www.google.com size=4 iconName=dialog-ok" 
TOP_OUTPUT=$(top -b -n 1 | head -n 20 | awk 1 ORS="\\\\n")
echo "$TOP_OUTPUT | font=monospace iconName=document-open"
