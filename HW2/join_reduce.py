#!/usr/bin/env python3
# Step 3
# Reduce step

"""

Purpose: join the trip and fare lines into a single line of data.

"""
from itertools import groupby
from operator import itemgetter
import sys
from datetime import datetime


# Define the indexes for each column in both the trip and fare data
# in order to make the code more flexible

# Trip data column index
trip_index = {'pickup' : 5,
              'dropoff' : 6,
              'time' : 8,
              'dist' : 9,
              'pickup_long' : 10,
              'pickup_latt': 11,
              'dropoff_long': 12,
              'dropoff_latt': 13}

# Fare data column index
fare_index = {'payment': 5,
              'total': 10}

dtime_fmt = "%Y-%m-%d %H:%M:%S"

def read_mapper_output(lines, separator = '\t'):
    for line in lines:
        yield line.rstrip().split(separator, 1)


def main():
    # Input comes from STDIN
    data = read_mapper_output(sys.stdin)
    for key, group in groupby(data, itemgetter(0)):
    
        # In every group we have a line from the "trip" table
        # and a line from the "fare" table. We assign them to different
        # sets
    
        trip = []
        fare = []
    
        for key, ride_line in group:
            ride_params = ride_line.strip().split(",")
            if len(ride_params) == 14: # trip data
                trip = ride_params
                # We create a datetime object, and in case of fail, get rid of the line
                try:
                    dropoff_time = datetime.strptime(trip[trip_index['dropoff']], dtime_fmt)
                    pickup_time = datetime.strptime(trip[trip_index['pickup']], dtime_fmt)
                except:
                    trip = []
            elif len(ride_params) == 11:
                fare = ride_params
            else:
                pass

	    # Get rid of the data that is obviously corrupt
        try:
	        # Don't write the line if either trip or fare is missing,
	        # or if it is the header

	        # TODO: set these thresholds
	        # Corrupt GPS pickup data
	        # Corrupt GPS dropoff data
	        # Free ride
	        # Too long or too short trips
	        # Unreasonably long or short trips
            if trip == [] or fare == [] or trip[0] == "medallion":
                pass

            # filter out obvious errors: trips too short or long, bad GPS data,
            # no fare, trips over 2 hours (7200 sec) or under 10 seconds
            # Similar filters as [1]
            elif float(trip[trip_index['dist']]) <= 0.001 \
            or float(trip[trip_index['dist']]) >= 50 \
            or float(trip[trip_index['pickup_long']]) == 0 \
            or float(trip[trip_index['pickup_latt']]) == 0 \
            or float(trip[trip_index['dropoff_long']]) == 0 \
            or float(trip[trip_index['dropoff_latt']]) == 0 \
            or float(fare[fare_index['payment']] == 0) \
            or float(fare[fare_index['total']]) == 0 \
            or (dropoff_time - pickup_time).total_seconds() >= 7200 \
            or (dropoff_time - pickup_time).total_seconds() < 10:
                pass

            else:
                print("\t".join(trip + fare[4:]))
        except:
            pass # get rid of the data


if __name__ == "__main__":
    main()

