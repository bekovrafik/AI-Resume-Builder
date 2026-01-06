import urllib.request
import json

url = "https://jooble.org/api/82608568-43f8-4566-971f-a242711dc749"
data = {"keywords": "Sales", "location": "London"}
json_data = json.dumps(data).encode("utf-8")

req = urllib.request.Request(url, data=json_data, headers={'Content-Type': 'application/json'})

try:
    print(f"Requesting to: {url}")
    print(f"Body: {data}")
    with urllib.request.urlopen(req) as response:
        print(f"Status Code: {response.getcode()}")
        print(f"Response: {response.read().decode('utf-8')}")
except Exception as e:
    print(f"Error: {e}")
