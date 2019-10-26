#!/usr/bin/env python3
"""
Created on Tue Oct 22 18:10:02 2019

@author: Lucas
"""

import sys
from datetime import datetime
from itertools import groupby

dtime_fmt = '%Y-%m-%d %H:%M:%S'
date_fmt = '%Y-%m-%d'

index = {'pickup' : 0,
         'dropoff': 1,
         'pass': 2,
         'trip': 3,
         'mile': 4,
         'earnings': 5}


def read_map():
    for line in sys.stdin:
        yield line.rstrip().split('\t')


def compute_onduty(times, min_break=30):
    """
    given a driver's trips during an hour, as well as a min_break input value 
    (in minutes), driver is assumed to be on break if:
        - they spend more than min_break minutes between two trips
        - they start his first trip more than min_break / 2 minutes after the hour begins
        - they end their last trip more than min_break / 2 minutes before the hour ends
    """
    t_onduty = 0
    times.sort(key=lambda x : datetime.strptime(x[0], dtime_fmt))
    
    time = times[0]
    start_time = datetime.strptime(time[0], dtime_fmt)
    end_time = datetime.strptime(time[1], dtime_fmt)
    
    start_hour = datetime(start_time.year, start_time.month, start_time.day, start_time.hour, 0, 0)
    end_hour = datetime(start_time.year, start_time.month, start_time.day, start_time.hour, 59, 59)
    
    if (start_time - start_hour).total_seconds() <= min_break * 60 / 2:
        t_onduty += (start_time - start_hour).total_seconds()
    t_onduty += (end_time - start_time).total_seconds()
    prev_time = end_time
    
    for time in times[1:]:
        start_time = datetime.strptime(time[0], dtime_fmt)
        end_time = datetime.strptime(time[1], dtime_fmt)
        if (start_time - prev_time).total_seconds() <= min_break * 60:
            t_onduty += (start_time - prev_time).total_seconds()
        t_onduty += (end_time - start_time).total_seconds()
        prev_time = end_time
    
    if (end_hour - prev_time).total_seconds() <= min_break * 60 / 2:
        t_onduty += (end_hour - prev_time).total_seconds()
        
    return t_onduty / 3599


def compute_occupied(times):
    t_occupied = 0
    
    for start, end in times:
        start = datetime.strptime(start, dtime_fmt)
        end = datetime.strptime(end, dtime_fmt)
        t_occupied += (end - start).total_seconds() / 3599
    
    return t_occupied


def main():
    lines = read_map()
    
    for key, group in groupby(lines, key=lambda x : x[0]):
        times = []
        n_pass, n_trip, n_mile, earnings = 0, 0, 0, 0
        
        for key, trip in group:
            trip = trip.rstrip().split(',')
            
            times.append((trip[index['pickup']], trip[index['dropoff']]))
            if int(trip[index['trip']]) == 1:
                n_pass += int(trip[index['pass']])
                n_trip += 1
            n_mile += float(trip[index['mile']])
            earnings += float(trip[index['earnings']])
            
        t_onduty = compute_onduty(times)
        t_occupied = compute_occupied(times)
            
        key = key.strip().split(',')
        print('\t'.join([key[0], key[1], key[2], \
                         str(t_onduty), str(t_occupied), str(n_pass), str(n_trip), str(n_mile), str(earnings)]))


if __name__ == "__main__":
    main()
