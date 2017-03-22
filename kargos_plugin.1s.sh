#!/bin/bash
echo "$(date)"
echo "---"
echo "Launch Gimp | bash=/usr/bin/gimp iconName=applications-graphics"
echo "Kernel: $(uname -r) | iconName=system-settings iconName=applications-development"
echo "Go to <i>Google</i> | href=http://www.google.com iconName=applications-internet" 
TOP_OUTPUT=$(top -b -n 1 | head -n 20 | awk 1 ORS="\\\\n")
echo "$TOP_OUTPUT | font=monospace iconName=applications-system"
