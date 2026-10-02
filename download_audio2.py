import urllib.request
import json
import os

FILES = {
    'cow': 'File:Cattle_mooing.ogg',
    'chicken': 'File:Rooster_crowing.ogg'
}

os.makedirs('assets/audio', exist_ok=True)

for name, title in FILES.items():
    file_url_api = f"https://commons.wikimedia.org/w/api.php?action=query&titles={urllib.parse.quote(title)}&prop=imageinfo&iiprop=url&format=json"
    req = urllib.request.Request(file_url_api, headers={'User-Agent': 'Mozilla/5.0'})
    fres = urllib.request.urlopen(req)
    fdata = json.loads(fres.read().decode('utf-8'))
    pages = fdata['query']['pages']
    for page_id in pages:
        if 'imageinfo' in pages[page_id]:
            url = pages[page_id]['imageinfo'][0]['url']
            print(f"Found {url}")
            filename = f"assets/audio/{name}.ogg"
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urllib.request.urlopen(req) as response, open(filename, 'wb') as out_file:
                out_file.write(response.read())
            print(f"Saved {filename}")
        else:
            print(f"Could not find {title}")
