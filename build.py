import requests
import xml.etree.ElementTree as ET

result = requests.get('http://frankorz.com/atom.xml')
feed = result.text
root = ET.fromstring(feed)
nsfeed = {'nsfeed': 'http://www.w3.org/2005/Atom'}
with open('README.md', 'w') as f:
    f.write(r'''

```
           _  .-')     ('-.         .-') _ .-. .-')               _  .-')     .-') _  
          ( \( -O )   ( OO ).-.    ( OO ) )\  ( OO )             ( \( -O )   (  OO) ) 
   ,------.,------.   / . --. /,--./ ,--,' ,--. ,--.  .-'),-----. ,------. ,(_)----.  
('-| _.---'|   /`. '  | \-.  \ |   \ |  |\ |  .'   / ( OO'  .-.  '|   /`. '|       |  
(OO|(_\    |  /  | |.-'-'  |  ||    \|  | )|      /, /   |  | |  ||  /  | |'--.   /   
/  |  '--. |  |_.' | \| |_.'  ||  .     |/ |     ' _)\_) |  |\|  ||  |_.' |(_/   /    
\_)|  .--' |  .  '.'  |  .-.  ||  |\    |  |  .   \    \ |  | |  ||  .  '.' /   /___  
  \|  |_)  |  |\  \   |  | |  ||  | \   |  |  |\   \    `'  '-'  '|  |\  \ |        | 
   `--'    `--' '--'  `--' `--'`--'  `--'  `--' '--'      `-----' `--' '--'`--------' 
```
                                                                                       

## Latest blog posts
''')
    for entry in root.findall('nsfeed:entry', nsfeed)[:5]:
        text = entry.find('nsfeed:title', nsfeed).text
        url = entry.find('nsfeed:link', nsfeed).attrib['href']
        published = entry.find('nsfeed:published', nsfeed).text[:10]
        f.write('- {} [{}]({})\n'.format(published, text, url))

    f.write('''
[>>> More blog posts](http://frankorz.com/archives/)

## Statistics
![Stats](https://github-readme-stats.vercel.app/api?username=latias94&theme=onedark)
![Lang](https://github-readme-stats.vercel.app/api/top-langs/?username=latias94&hide=javascript,html,c&layout=compact)
''')
