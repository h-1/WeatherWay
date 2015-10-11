import urllib
from pprint import pprint
import json
import xml.etree.ElementTree as ET

locations = []


with open('accidents.json') as data_file:
	data = json.load(data_file)
	for place in data:
		lat = place["Latitude"]
		lng = place["Longitude"]
		dicLoc = {"lat":lat,"lng":lng,"danger":False}
		locations.append(dicLoc)

def checkDanger(step):
	stepLoc = step["start_location"]
	lat = round(stepLoc["lat"],2)
	lng = round(stepLoc["lng"],2)
	for danger in locations:
		if lat == round(danger["lat"],2) and lng == round(danger["lng"],3):
			print("DANGER")
			print(danger)
			print(step["polyline"])
			if locations.index(danger) != len(locations) -1:
				print(locations[locations.index(danger)+1])
				getAlternativeForDanger(danger,locations[locations.index(danger)+1])
			# locations[locations.index(danger)]["danger"] = True

def getAlternativeForDanger(sLoc,eLoc):
	#start
	sLat = sLoc["lat"]
	sLng = sLoc["lng"]
	#End
	eLat = eLoc["lat"]
	eLng = eLoc["lng"]

	url = "https://maps.googleapis.com/maps/api/directions/json?origin=" + str(sLat) + "," + str(sLng) + "&destination=" + str(eLat) + "," + str(eLng) + "&mode=driving&sensor=false"
	u = urllib.urlopen(url)
# u is a file-like object
	data = u.read()
	routes = json.loads(data)

	steps = routes["routes"][0]["legs"][0]["steps"]
	for step in steps:
		pprint(step["polyline"])
	print("=======")


url = 'https://maps.googleapis.com/maps/api/directions/json?origin=47.606209,-122.332071&destination=47.616452,-122.297895&mode=driving&sensor=false'
u = urllib.urlopen(url)
# u is a file-like object
data = u.read()
routes = json.loads(data)

steps = routes["routes"][0]["legs"][0]["steps"]
for step in steps:
	stepLoc = step["start_location"]

	
#loc: 
	#lat:Double
	#lng":Double
	#time: 00:00:00
def getDBZForLoc(loc):
	url = "http://api.weather.com/beta/datacloud/?datatype=forecast&vs=1.0&passkey=d972da81e1ce2f854f9a5560ffb6f243&type=point&var=PrecipIntensity&lat=" + loc["lat"] + "&lon=" + loc["lng"] + "&format=hourly&time=now+" + loc["time"]
	u = urllib.urlopen(url)
	data = u.read()
	split1 = data.split("dbz")[1]
	split2 = split1[2:]
	split3 = split2.split("</P")[0]
	return float(split3)
	# checkDanger(step)

