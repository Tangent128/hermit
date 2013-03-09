# by dergemkr
# This script grabs the list of unicode characters (and character ranges) from
# the Unicode website and puts them into a format that hermit
# https://github.com/tangent128/hermit can understand.

import re
import urllib.request

exp = re.compile('''^<tr><td>(.+?)</td><td><a[^>]+>(.+?)</a></td></tr>''')
toScan = urllib.request.urlopen("http://www.unicode.org/charts/charindex.html")

for line in toScan:
    line = line.decode("utf-8")
    match = exp.match(line)
    if match:
        try:
            kwords = match.group(1).lower().replace(",", "")
            char = chr(int(match.group(2), 16))
            print("%s %s" % (char, kwords))
        except UnicodeEncodeError:
            pass
    
toScan.close()
