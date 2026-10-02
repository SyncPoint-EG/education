import urllib.request
import json
url = f"https://commons.wikimedia.org/w/api.php?action=query&list=search&srsearch=cattle&srnamespace=6&format=json"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
response = urllib.request.urlopen(req)
data = json.loads(response.read().decode('utf-8'))
for item in data['query']['search']:
    title = item['title']
    if title.lower().endswith('.ogg') or title.lower().endswith('.wav') or title.lower().endswith('.mp3'):
        print(title)
