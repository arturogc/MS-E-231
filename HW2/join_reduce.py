#!/usr/bin/env python2.7

# Step 3
# Reduce step

"""

Purpose: Reducer to take a sorted list of trip and fare data lines and join them
into a single line of data with all unique data values.

"""
from datetime import datetime
from itertools import groupby
from operator import itemgetter
import sys

# Constants for data filtering. *_IDX indicates index in the data list
# trip constants
TRIPTIME      = 60
PICKUP_TIME_IDX = 5
DROPOFF_TIME_IDX = 6
TRIPTIME_IDX  = 8
TRIP_DIST_IDX = 9
PICK_LONG_IDX = 10
PICK_LATT_IDX = 11
DROP_LONG_IDX = 12
DROP_LATT_IDX = 13

#fare constants
FARE_IDX         = 5
TOTAL_AMOUNT_IDX = 10

FORMAT = "%Y-%m-%d %H:%M:%S"

def read_mapper_output(lines):
    """Returns generator over each line of lines as a list split by tabs."""
    for line in lines:
        #print(line.rstrip().split('\t', 1))
        yield line.rstrip().split('\t', 1)


"""Take lines from stdin and join the trip and fare data lines.
   Do a JOIN, where `trip` is left and 'fare' is right
"""
data = read_mapper_output(sys.stdin)
for key, group in groupby(data, itemgetter(0)):
    # [Mine] In every group we have a line from the "trip" table
    # and a line from the "fare" table. We assign them to different
    # sets

    trip = []
    fare = []

    for key, ride_data in group:
        ride_data_list = ride_data.strip().split(",")
        if len(ride_data_list) == 14: # trip data
            trip = ride_data_list
            # if we can't create a good datetime object, get rid of the data
            try:
                dropoff_time = datetime.strptime(trip[DROPOFF_TIME_IDX], FORMAT)
                pickup_time = datetime.strptime(trip[PICKUP_TIME_IDX], FORMAT)
            except:
                trip = []
        elif len(ride_data_list) == 11:
            fare = ride_data_list
        else:
            pass

    # try to filter the data. If there is anything wrong with it here,
    # just get rid of it
    try:
        # Make sure there are two data lines and get ride of the header
        if trip == [] or fare == [] or trip[0] == "medallion":
            pass

        # filter out obvious errors: trips too short or long, bad GPS data,
        # no fare, trips over 2 hours (7200 sec) or under 10 seconds
        # Similar filters as [1]
        elif float(trip[TRIP_DIST_IDX]) <= 0.001 \
        or float(trip[TRIP_DIST_IDX]) >= 50 \
        or float(trip[PICK_LATT_IDX]) == 0 \
        or float(trip[PICK_LONG_IDX]) == 0 \
        or float(trip[DROP_LATT_IDX]) == 0 \
        or float(trip[DROP_LONG_IDX]) == 0 \
        or float(fare[FARE_IDX] == 0) \
        or float(fare[TOTAL_AMOUNT_IDX]) == 0 \
        or (dropoff_time - pickup_time).total_seconds() >= 7200 \
        or (dropoff_time - pickup_time).total_seconds() < 10:
            pass

        else:
            print("\t".join(trip + fare[4:]))
    except:
        #print("ERRRRRRRRRRRROOOOOOOOOOORRRRRRRRRRRR!")
        pass # get rid of the data

