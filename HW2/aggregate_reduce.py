#!/usr/bin/env python3
"""
Step 5: reduce
"""

import sys
from itertools import groupby
from operator import itemgetter

index = {
	't_onduty': 0,
	't_occupied': 1,
	'n_pass': 2,
	'n_trip': 3,
	'n_mile': 4,
	'earnings': 5
}

def read_mapper_output(lines, separator = '\t'):
    for line in lines:
        yield line.rstrip().split(separator, 1)

def main():
	# Input comes from STDIN
    lines = read_mapper_output(sys.stdin)

    for key, group in groupby(lines, itemgetter(0)):
    	# We want the following structure:
    	# date, hour, drivers_onduty, t_onduty, t_occupied, n_pass, n_trip, n_mile, earnings

        drivers_onduty, t_onduty, t_occupied, n_pass, n_trip, n_mile, earnings = 0,0,0,0,0,0,0

        key_values = key.strip().split(",")

        for hour in group:
        	hourly_data = hour[1].strip().split(",")

        	if (float(hourly_data[index['t_onduty']]) > 0.017):
        		drivers_onduty += 1

        	t_onduty += float(hourly_data[index['t_onduty']])
        	t_occupied += float(hourly_data[index['t_occupied']])
        	n_pass += float(hourly_data[index['n_pass']])
        	n_trip += float(hourly_data[index['n_trip']])
        	n_mile += float(hourly_data[index['n_mile']])
        	earnings += float(hourly_data[index['earnings']])

        print("\t".join([key_values[0], key_values[1], str(drivers_onduty), str(t_onduty), \
        	str(t_occupied), str(n_pass), str(n_trip), str(n_mile), str(earnings)]))




if __name__ == "__main__":
    main()