# http://api.wunderground.com/api/9519659bd4c949e4/history_20151009/q/47.615862547,-122.309496855.json
import csv
import json
import urllib2
import itertools
from math import cos, sin, atan2, sqrt, pi
from datetime import date, timedelta, datetime
from sklearn import svm

# Create a list to contain data
traffic_accidents = []

# ====================================================
# Sample data for traffic accident
# CAD CDW ID  CAD Event Number    General Offense Number  Event Clearance Code    Event Clearance Description Event Clearance SubGroup    Event Clearance Group   Event Clearance Date    Hundred Block Location  District/Sector Zone/Beat   Census Tract    Longitude   Latitude
# 2258108 15000029968 201529968   430 ACCIDENT INVESTIGATION  TRAFFIC RELATED CALLS   ACCIDENT INVESTIGATION  01/27/2015 01:02:00 PM  17XX BLOCK OF E MADISON ST  G   G1  7900.4  -122.309496855  47.615862547

# Load traffic dataset
with open('/resources/Traffic_Accidents.csv') as csvfile:
    # Skip header line
    csvfile.next()
    reader = csv.reader(csvfile)
    for row in reader:
        traffic_accidents.append([row[7], row[12], row[13]])

# Examine data
# print traffic_accidents[0]
# [date, long, lat]
# ['01/27/2015 01:02:00 PM', '-122.309496855', '47.615862547']

def transform_dateset(row):
    # dataset doesn't have a date
    if row[0] == '':
        return []

    date_time = datetime.strptime(row[0], '%m/%d/%Y %I:%M:%S %p').date().strftime("%Y%m%d")
    longitude = row[1]
    latitude = row[2]

    return (date_time, (latitude, longitude))

traffic_accidents = map(transform_dateset, traffic_accidents)

# Examine data
print traffic_accidents[0]
# [date, lat, lon]
# ('20150127', ('47.615862547', '-122.309496855'))
# long, lat is accurate to 1 km

# ============================================
# Data aggregation

# Calculate center point from a list of locations
def center_geolocation(geolocations):
    """
    Provide a relatively accurate center lat, lon returned as a list pair, given
    a list of list pairs.
    ex: in: geolocations = ((lat1,lon1), (lat2,lon2),)
        out: (center_lat, center_lon), sum of num of points
    """
    x = 0
    y = 0
    z = 0
    length = len(geolocations)

    for lat, lon in geolocations:
        lat = float(lat) * (pi / 180)
        lon = float(lon) * (pi / 180)
        x += cos(lat) * cos(lon)
        y += cos(lat) * sin(lon)
        z += sin(lat)

    x = float(x / length)
    y = float(y / length)
    z = float(z / length)

    return (atan2(z, sqrt(x * x + y * y)) * (180 / pi), atan2(y, x) * (180 / pi)), length

# get historical weather condition based on list of lats and longs
def get_hist_weather(date, lat, lon):
    url = "http://api.wunderground.com/api/9519659bd4c949e4/history_" + date + "/q/" + str(lat) + "," + str(lon) + ".json"
    return json.load(urllib2.urlopen(url))

def de_list(lis):
    return reduce(lambda a, b: a + b, lis)

# ================================================
# Weather API + wunderground API

# Retrieve only necessary information
def parse_JSON(date, geocode):
    # Get json data from web
    JSON_Obj = get_hist_weather(date, geocode[0], geocode[1]);

    # Retrieve needed info
    fog = JSON_Obj["history"]["dailysummary"][0]["fog"]
    rain = JSON_Obj["history"]["dailysummary"][0]["rain"]
    snow = JSON_Obj["history"]["dailysummary"][0]["snow"]
    hail = JSON_Obj["history"]["dailysummary"][0]["hail"]
    thunder = JSON_Obj["history"]["dailysummary"][0]["thunder"]
    tornado = JSON_Obj["history"]["dailysummary"][0]["tornado"]
    meandewptm = JSON_Obj["history"]["dailysummary"][0]["meandewptm"]
    meanwindspdm = JSON_Obj["history"]["dailysummary"][0]["meanwindspdm"]
    meanvism = JSON_Obj["history"]["dailysummary"][0]["meanvism"]
    maxtempm = JSON_Obj["history"]["dailysummary"][0]["maxtempm"]
    mintempm = JSON_Obj["history"]["dailysummary"][0]["mintempm"]
    precipi = JSON_Obj["history"]["dailysummary"][0]["precipi"]

    result_list = [
        fog,
        rain,
        snow,
        hail,
        thunder,
        tornado,
        meandewptm,
        meanwindspdm,
        meanvism,
        maxtempm,
        mintempm,
        precipi
    ]

    return cleanse_JSON(result_list)

def predict_JSON(geocode):
    lat = str(geocode[0])
    lon = str(geocode[1])
    url = "http://api.weather.com/v1/geocode/" + lat + "/" + lon + "/observations/current.json?apiKey=d972da81e1ce2f854f9a5560ffb6f243&language=en-US&units=m"
    # Get json data from web
    JSON_Obj = json.load(urllib2.urlopen(url))

    # Retrieve needed info
    meandewptm = JSON_Obj["observation"]["metric"]["dewpt"]
    meanwindspdm = JSON_Obj["observation"]["metric"]["wspd"]
    meanvism = JSON_Obj["observation"]["metric"]["vis"]
    maxtempm = JSON_Obj["observation"]["metric"]["temp_max_24hour"]
    mintempm = JSON_Obj["observation"]["metric"]["temp_min_24hour"]
    precipi = JSON_Obj["observation"]["metric"]["precip_1hour"]

    result_list = [
        meandewptm,
        meanwindspdm,
        meanvism,
        maxtempm,
        mintempm,
        precipi
    ]

    return cleanse_JSON(result_list)

def cleanse_JSON(result_list):
    new_list = []

    # Cleanse data; empty value, -9999, etc
    for condition in result_list:
        try:
            condition_str = float(condition)
            if (condition_str < 0):
                condition_str = 0.0
        except ValueError:
            condition_str = 0.0
        new_list.append(condition_str)

    # verify results only contain floats
    for condition in new_list:
        if (type(condition) != float):
            new_list.append("!!!!!!!!!!!!!!!!!!" + str(condition))

    return new_list


# print parse_JSON('20150127', ('47.69351384192733', '-122.31278465652628'))

traffic_accidents_RDD = sc.parallelize(traffic_accidents)

cleanRDD = (traffic_accidents_RDD.filter(lambda x: x)
                                 .mapValues(lambda x: [x])
                                 .reduceByKey(lambda a, b: a + b))
cleanRDD.persist()
# print cleanRDD.take(1)
# [('20130824', [('47.686688445', '-122.313357793'), ('47.700339236', '-122.31221137')])]

# TODO: Ask for most accurate hourly data?

full_traffic_accidents_RDD = (cleanRDD.mapValues(lambda geopoints: center_geolocation(geopoints))
                                      .map(lambda (date, point_count): (date, point_count[0][0], point_count[0][1], point_count[1], parse_JSON(date, point_count[0]))))

full_traffic_accidents_RDD.persist()

output_traffic = full_traffic_accidents_RDD.collect()
with open("output_traffic.csv", "wb") as f:
    writer = csv.writer(f)
    writer.writerows(output_traffic)

# Python clean steps
# 1. Get date range from start to end
# 2. filter out dates that don't have accident
# 3. combine keys
# 4. get weather data
# 5. flatten into one row of data, not in tuple or array
# 6. Perform a collect and write to csv like regular files not RDD

# R steps
# 1. Turn files into csv
# 2. Use that to perform ggplot2, rain X accident total, may need facet
# 3. Do a SVM model
# 4. train, validate, test

# Python steps
# 1. Use SKlearn to do svm
# 2. also try kNN
# 3. try predict, see accuracy

# ==============================================================================
# ==============================================================================
# ==============================================================================
# ==============================================================================
# ==============================================================================
# ==============================================================================
# run data exploration and model fit in R
# [count, 1-6 features, danger]
def danger_level(count):
    if (count <= 5):
        return "No danger"
    if (count <= 25):
        return "Small danger"
    if (count <= 45):
        return "Mid danger"
    return "High danger"

features = []
labels = []

with open('/resources/simple_model_data.csv') as csvfile:
    # Skip header line
    csvfile.next()
    reader = csv.reader(csvfile)
    for row in reader:
        labels.append(row[-1])
        features.append(map(float, row[1:-1]))

# model fit
model_class = svm.SVC()
model_class.fit(features, labels)

# test model prediction
predict_result = model_class.predict([predict_JSON(('47.6062095', '-122.3320708'))])
print predict_result

# TODO: Implement while loop to listen to server