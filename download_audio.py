import urllib.request
import json
import os

ANIMALS = ['cow moo', 'chicken cluck', 'goat bleat']

def get_wikimedia_audio(query):
    url = f"https://commons.wikimedia.org/w/api.php?action=query&list=search&srsearch={urllib.parse.quote(query)}&srnamespace=6&format=json"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    response = urllib.request.urlopen(req)
    data = json.loads(response.read().decode('utf-8'))
    
    for item in data['query']['search']:
        title = item['title']
        if title.lower().endswith('.ogg') or title.lower().endswith('.wav') or title.lower().endswith('.mp3'):
            file_url_api = f"https://commons.wikimedia.org/w/api.php?action=query&titles={urllib.parse.quote(title)}&prop=imageinfo&iiprop=url&format=json"
            freq = urllib.request.Request(file_url_api, headers={'User-Agent': 'Mozilla/5.0'})
            fres = urllib.request.urlopen(freq)
            fdata = json.loads(fres.read().decode('utf-8'))
            pages = fdata['query']['pages']
            for page_id in pages:
                return pages[page_id]['imageinfo'][0]['url']
    return None

os.makedirs('assets/audio', exist_ok=True)

for animal in ANIMALS:
    print(f"Searching for {animal}...")
    url = get_wikimedia_audio(animal)
    if url:
        print(f"Found {url}")
        filename = f"assets/audio/{animal.split()[0]}.ogg"
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response, open(filename, 'wb') as out_file:
            out_file.write(response.read())
        print(f"Saved {filename}")
    else:
        print(f"Could not find audio for {animal}")
