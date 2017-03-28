#!/usr/bin/env python
import sys
# sys.setdefaultencoding() does not exist, here!

import urllib2
import xml.etree.ElementTree as ET

reload(sys)  # Reload does the trick!
sys.setdefaultencoding('UTF8')

# limit the number of items per url. -1= no limit
MAX=-1

urls = [
    # (url,icon). icon maybe empty string
    ('https://dot.kde.org/rss.xml', 'https://dot.kde.org/sites/all/themes/neverland/logo.png'),
    ('https://dot.kde.org/rss.xml', '')
]



print "---"
print "Refresh|refresh=true iconName=view-refresh"
for (url, icon) in urls:
    
    response = urllib2.urlopen(url)
    html = response.read()

    try:
        root = ET.fromstring(html)
        count = 0
        for item in root.findall('.//item'):
            if count == MAX:
                    break
            count += 1
            title = item.find('title').text
            link = item.find('link').text
            line = title.replace('|', '/') + '| href=' + link
            if (icon !=None and icon != ''):
                line+=' imageWidth=22 imageHeight=22 imageURL='+icon
            else:
                line+=' iconName=application-rss+xml'
            print line
            print line + ' dropdown=false'
    except:
        line = 'error fetching '+url+'|'
        if (icon !=None and icon != ''):
            line+=' imageWidth=22 imageHeight=22 imageURL='+icon
        else:
            line+=' iconName=application-rss+xml'
        print line
        print line + ' dropdown=false'    
