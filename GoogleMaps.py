import urllib
from pprint import pprint
import json
import xml.etree.ElementTree as ET
import datetime
from flask import Flask, request, redirect, session, url_for
app = Flask(__name__)
import os
from flask import current_app
locations = []
plusTimes = []
steps = []
returnDirections=[]
def isRaining(lat,lng,time):
	print"rain"
	time = "40:00:00"
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
	pprint(step)
	print("check")
	stepLoc = step["start_location"]
	lat = stepLoc["lat"]
	lng = stepLoc["lng"]
	print(isRaining(lat,lng,getTimeForStep(step)))

	#If it is raining, check for dangerous areas
	if isRaining(lat,lng,getTimeForStep(step)):
		for danger in locations:
			if round(lat,2) == round(danger["lat"],2) and round(lng,2) == round(danger["lng"],2):
				print("DANGER")
				# if locations.index(danger) != len(locations) -1:
					# print(locations[locations.index(danger)+1])
				if steps.index(step) < len(steps)-1:
					getAlternativeForDanger(step,steps[steps.index(step)+1])
				else:
					step2 = step
					step2["start_location"] = step["end_location"]
					getAlternativeForDanger(step,step2)

def getAlternativeForDanger(step,step2):
	#start
	stepLoc = step["start_location"]
	sLat = stepLoc["lat"]
	sLng = stepLoc["lng"]
	
	#End
	stepLoc2 = step2["start_location"]
	eLat = stepLoc2["lat"]
	eLng = stepLoc2["lng"]

	#Alternative
	aLat = eLat + 0.001
	aLng = eLng - 0.001

	url = "https://maps.googleapis.com/maps/api/directions/json?origin=" + str(sLat) + "," + str(sLng) + "&destination=" + str(eLat) + "," + str(eLng) + "&waypoints=" + str(aLat) + "," + str(aLng) + "&mode=driving&sensor=false&alternatives=true"
	# print(url)
	u = urllib.urlopen(url)
# u is a file-like object
	data = u.read()
	routes = json.loads(data)
	# pprint(routes)
	legs = routes["routes"][0]["legs"]
	leg1 = legs[0]["steps"]
	leg2 = legs[1]["steps"]

	leg1.extend(leg2)

	#replacing first step
	if step in returnDirections:
		returnDirections.remove(step)

	index = steps.index(step)
	for item in leg1:
		returnDirections.insert(index,item)
		index +=1



	# print("alt:")
	# pprint(len(steps))
	# pprint(len(returnDirections))
	# steps[steps.index(step)] = alternateStep

#given step, returns time in 00:00:00 format/
def getTimeForStep(step): 
	index = steps.index(step)
	plusTime = plusTimes[index]

	return "00:" + ('%02d' % (plusTime/60)) + ":00"



@app.route("/")
def index():
    return json.dumps(returnDirections)

@app.route("/getDirections")
def direct():
	#current location
	cLat = str(request.args['cLat'])
	cLng = str(request.args['cLng'])
	#destination's location
	dLat = str(request.args['dLat'])
	dLng = str(request.args['dLng'])	
	print(cLat)
	print(cLng)
	print(dLat)
	print(dLng)
	url = "https://maps.googleapis.com/maps/api/directions/json?origin=" + cLat + "," + cLng + "&destination=" + dLat + "," + dLng + "&mode=driving&sensor=false&alternatives=true"
	print(url)
	u = urllib.urlopen(url)
	# u is a file-like object
	data = u.read()
	# print(data)
	routes = json.loads(data)

	steps = routes["routes"][0]["legs"][0]["steps"]
	returnDirections = list(steps)
	# pprint(steps)
	for step in steps:
		currentTime = 0
		if  len(plusTimes) >0:
			currentTime = plusTimes[len(plusTimes)-1]

		currentTime += int(step["duration"]["value"])
		plusTimes.append(currentTime)
		stepLoc = step["start_location"]
		checkDanger(step)
	return json.dumps(returnDirections)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)


