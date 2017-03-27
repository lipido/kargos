#!/usr/bin/env python
import sys
# sys.setdefaultencoding() does not exist, here!

import urllib2
import xml.etree.ElementTree as ET

reload(sys)  # Reload does the trick!
sys.setdefaultencoding('UTF8')

urls = [ 
	'https://dot.kde.org/rss.xml'
]


print "---"
print "Refresh|refresh=true"
for url in urls:
    
    response = urllib2.urlopen(url)
    html = response.read()


    root = ET.fromstring(html)


    for country in root.findall('.//item'):
        title = country.find('title').text
        link = country.find('link').text
        print title.replace('|', '/') + '| iconName=application-rss+xml dropdown=false href=' + link
        print title.replace('|', '/') + '| iconName=application-rss+xml href=' + link

