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
date_range_set = set()
# Start date of traffic accident data
start_date = date(2010, 7, 18)
# End date of traffic accident data
end_date = date(2015, 1, 28)

# Create a set of dates
def daterange(start_date, end_date):
    for n in range(int ((end_date - start_date).days)):
        yield start_date + timedelta(n)

for single_date in daterange(start_date, end_date):
    date_range_set.add(single_date.strftime("%Y%m%d"))

# Should have 1655 days total
print len(date_range_set)

# Prepare date rdd, pair with geocode of Seattle and 0 accidents
# date_RDD = sc.parallelize(date_range_set).map(lambda x: (x, ('47.6062095', '-122.3320708'), 0))

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

    date_time = date.strptime(row[0], '%m/%d/%Y %I:%M:%S %p').date().strftime("%Y%m%d")
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
# TODO: Ask for most accurate hourly data?

# Retrieve only necessary information
def parse_JSON(date, geocode):
    # Get json data from web
    JSON_Obj = get_hist_weather(date, geocode[0], geocode[1]);

    # Retrieve needed info
    fog = JSON_Obj["history"]["dailysummary"][0]["fog"]
    rain = JSON_Obj["history"]["dailysummary"][0]["rain"]
    snow = JSON_Obj["history"]["dailysummary"][0]["snow"]
    snowfalli = JSON_Obj["history"]["dailysummary"][0]["snowfalli"]
    snowdepthi = JSON_Obj["history"]["dailysummary"][0]["snowdepthi"]
    hail = JSON_Obj["history"]["dailysummary"][0]["hail"]
    thunder = JSON_Obj["history"]["dailysummary"][0]["thunder"]
    tornado = JSON_Obj["history"]["dailysummary"][0]["tornado"]
    meantempi = JSON_Obj["history"]["dailysummary"][0]["meantempi"]
    meandewpti = JSON_Obj["history"]["dailysummary"][0]["meandewpti"]
    meanpressurei = JSON_Obj["history"]["dailysummary"][0]["meanpressurei"]
    meanwindspdi = JSON_Obj["history"]["dailysummary"][0]["meanwindspdi"]
    meanwdire = JSON_Obj["history"]["dailysummary"][0]["meanwdire"]
    meanwdird = JSON_Obj["history"]["dailysummary"][0]["meanwdird"]
    meanvisi = JSON_Obj["history"]["dailysummary"][0]["meanvisi"]
    humidity = JSON_Obj["history"]["dailysummary"][0]["humidity"]
    maxtempi = JSON_Obj["history"]["dailysummary"][0]["maxtempi"]
    mintempi = JSON_Obj["history"]["dailysummary"][0]["mintempi"]
    maxhumidity = JSON_Obj["history"]["dailysummary"][0]["maxhumidity"]
    minhumidity = JSON_Obj["history"]["dailysummary"][0]["minhumidity"]
    maxdewpti = JSON_Obj["history"]["dailysummary"][0]["maxdewpti"]
    mindewpti = JSON_Obj["history"]["dailysummary"][0]["mindewpti"]
    maxpressurei = JSON_Obj["history"]["dailysummary"][0]["maxpressurei"]
    minpressurei = JSON_Obj["history"]["dailysummary"][0]["minpressurei"]
    maxwspdi = JSON_Obj["history"]["dailysummary"][0]["maxwspdi"]
    minwspdi = JSON_Obj["history"]["dailysummary"][0]["minwspdi"]
    maxvisi = JSON_Obj["history"]["dailysummary"][0]["maxvisi"]
    minvisi = JSON_Obj["history"]["dailysummary"][0]["minvisi"]
    precipi = JSON_Obj["history"]["dailysummary"][0]["precipi"]

    # cleanse data
    # if (precipi == "T"):
    #     precipi = 0.00

    # if (snowfalli == "T"):
    #     snowfalli = 0.00

    result_list = [
        fog,
        rain,
        snow,
        snowfalli,
        snowdepthi,
        hail,
        thunder,
        tornado,
        meantempi,
        meandewpti,
        meanpressurei,
        meanwindspdi,
        meanwdire,
        meanwdird,
        meanvisi,
        humidity,
        maxtempi,
        mintempi,
        maxhumidity,
        minhumidity,
        maxdewpti,
        mindewpti,
        maxpressurei,
        minpressurei,
        maxwspdi,
        minwspdi,
        maxvisi,
        minvisi,
        precipi
    ]

    new_list = []

    # Cleanse data; empty value, -9999, etc
    for condition in result_list:
        condition_str = condition.encode("utf-8")
        if (not condition_str or
            condition_str == "T" or
            condition_str == "-999" or
            condition_str == "-999.00" or
            condition_str == "-9999" or
            condition_str == "-9999.00"):
            condition_str = 0.00
        else:
            condition_str = float(condition_str)
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

# ================================================
# Merge two RDDs; Join traffic_accidents_RDD with date_RDD
# 1. Get list of dates from traffic_accidents_RDD
traffic_dates = set(cleanRDD.keys().collect())
# 2. Get difference between traffic_dates and date_range_set
different_dates = list(date_range_set - traffic_dates)
different_RDD = (sc.parallelize(different_dates)
                   .map(lambda date: (date, '47.6062095', '-122.3320708', 0, parse_JSON(date, ('47.6062095', '-122.3320708')))))
output_zero = different_RDD.collect()
# print different_RDD.take(1)

# Output to csv
with open("output_zero.csv", "wb") as f:
    writer = csv.writer(f)
    writer.writerows(output_zero)

full_traffic_accidents_RDD = (cleanRDD.mapValues(lambda geopoints: center_geolocation(geopoints))
                                      .map(lambda (date, point_count): (date, point_count[0][0], point_count[0][1], point_count[1], parse_JSON(date, point_count[0]))))

output_traffic = full_traffic_accidents_RDD.collect()
with open("output_traffic.csv", "wb") as f:
    writer = csv.writer(f)
    writer.writerows(output_traffic)








# 3. Add dates without traffic accidents to dataset
full_traffic_accidents_RDD = cleanRDD.mapValues(lambda geopoints: center_geolocation(geopoints))
full_traffic_accidents_RDD = full_traffic_accidents_RDD.map(lambda (date, point_count): (date, point_count[0][0], point_count[0][1], point_count[1], parse_JSON(date, point_count[0]))

(different_RDD.fullOuterJoin(full_traffic_accidents_RDD)
                                                       .map(lambda (date, point_count): (date, point_count[0][0], point_count[0][1], point_count[1], parse_JSON(date, point_count[0]))))

full_traffic_accidents_RDD.persist()
print full_traffic_accidents_RDD.take(1)
out_csv = full_traffic_accidents_RDD.collect()

# Output to csv
with open("output.csv", "wb") as f:
    writer = csv.writer(f)
    writer.writerows(out_csv)


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
model = []
features = []
labels = []

with open('/resources/model_data.csv') as csvfile:
    # Skip header line
    csvfile.next()
    reader = csv.reader(csvfile)
    for row in reader:
        model.append(row)

for row in model:
    labels.append(row[-1])
    features.append(map(float, row[:-1]))

# model fit
model_class = svm.SVC()
model_class.fit(features, labels)

# test model prediction
predict_result = model_class.predict([parse_JSON('20151015', ('47.6062095', '-122.3320708'))])
print predict_result

# TODO: Implement while loop to listen to server