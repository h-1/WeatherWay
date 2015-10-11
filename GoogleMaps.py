import urllib
from pprint import pprint
import json
import xml.etree.ElementTree as ET
import datetime

locations = []
plusTimes = []
steps = []
def isRaining(lat,lng,time):
	url = "http://api.weather.com/beta/datacloud/?datatype=forecast&vs=1.0&passkey=d972da81e1ce2f854f9a5560ffb6f243&type=point&var=PrecipIntensity&lat=" + str(lat) + "&lon=" + str(lng) + "&format=hourly&time=now+" + str(time)
	u = urllib.urlopen(url)
	data = u.read()
	split1 = data.split("dbz")[1]
	split2 = split1[2:]
	split3 = split2.split("</P")[0]
	
	if float(split3)>0:
		return True
	else:
		return False


with open('accidents.json') as data_file:
	data = json.load(data_file)
	for place in data:
		lat = place["Latitude"]
		lng = place["Longitude"]
		dicLoc = {"lat":lat,"lng":lng,"danger":False}
		locations.append(dicLoc)

def checkDanger(step):
	#Check if it is Raining on that Step
	stepLoc = step["start_location"]
	lat = stepLoc["lat"]
	lng = stepLoc["lng"]

	#If it is raining, check for dangerous areas
	if isRaining(lat,lng,getTimeForStep(step)):
		print(isRaining(lat,lng,getTimeForStep(step)))
		for danger in locations:
			if round(lat,2) == round(danger["lat"],2) and round(lng,2) == round(danger["lng"],2):
				print("DANGER")
				# if locations.index(danger) != len(locations) -1:
					# print(locations[locations.index(danger)+1])
				# getAlternativeForDanger(danger,locations[locations.index(danger)+1])
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

#given step, returns time in 00:00:00 format/
def getTimeForStep(step):
	index = steps.index(step)
	plusTime = plusTimes[index]

	return "00:" + ('%02d' % (plusTime/60)) + ":00"

url = 'https://maps.googleapis.com/maps/api/directions/json?origin=47.806209,-122.332071&destination=47.616452,-122.297895&mode=driving&sensor=false'
u = urllib.urlopen(url)
# u is a file-like object
data = u.read()
# print(data)
routes = json.loads(data)

steps = routes["routes"][0]["legs"][0]["steps"]
for step in steps:
	currentTime = 0
	if  len(plusTimes) >0:
		currentTime = plusTimes[len(plusTimes)-1]

	currentTime += step["duration"]["value"]
	plusTimes.append(currentTime)
	stepLoc = step["start_location"]
	checkDanger(step)
