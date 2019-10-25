#!/usr/bin/env python3
# Step 3
# Map step

import sys

"""

For each line of data, it emits the following (key,value) pais:
    - Key: medallion,starttime
    - Value: line

"""

def main():
    for line in sys.stdin:
    	# We input the first line
        params = line.strip().split(",")
    	
    	# The line may be from either table (fares.csv or trip.csv), so we have to identify it:
    	# From the trips table
        if len(params) == 14: # trip data
            key = params[0] + "," + params[5]
        # From the fare table
        elif len(params) == 11: # fare data
            key = params[0] + "," + params[3]
        else:
            key = "NA"

        # We now print the result, unless it is a header!
        if key[0].isdigit():
        	# Print the key and the value, with a tab in between
            print(key + "\t" + line.strip())
        else:
            pass

if __name__ == "__main__":
    main()