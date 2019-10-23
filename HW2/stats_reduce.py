# -*- coding: utf-8 -*-
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


def compute_onduty(times):
    times.sort(key=lambda x : datetime.strptime(x[0], dtime_fmt))
    pass


def compute_occupied(times):
    t_occupied = 0
    
    for start, end in times:
        start = datetime.strptime(start, dtime_fmt)
        end = datetime.strptime(end, dtime_fmt)
        t_occupied += (end - start).total_seconds() / 3600
    
    return t_occupied


if __name__ == 'main':
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
