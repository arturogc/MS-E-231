# -*- coding: utf-8 -*-
"""
Created on Wed Oct 16 17:32:45 2019

@author: Lucas
"""

import sys
from datetime import datetime

dtime_fmt = '%Y-%m-%d %H:%M:%S'
date_fmt = '%Y-%m-%d'

index = {'hack' : 1,
         'start' : 5,
         'end' : 6,
         'pass' : 7,
         'mile' : 9,
         'earnings' : 20}


if __name__ == 'main':
    
    for line in sys.stdin:
        line = line.strip().split('\t')
        
        driver = line[index['hack']]
        start = datetime.strptime(line[index['start']], dtime_fmt)
        end = datetime.strptime(line[index['end']], dtime_fmt)
        n_pass = int(line[index['pass']])
        n_mile = float(line[index['mile']])
        earnings = float(line[index['earnings']])
        
        if start.hour == end.hour:
            key = ",".join([str(start.hour), datetime.strftime(start, date_fmt), driver])
            val = ",".join([datetime.strftime(start, dtime_fmt), datetime.strftime(end, dtime_fmt), n_pass, 1, n_mile, earnings])
            print(key + "\t" + val)
        
        elif (end.hour == start.hour + 1) or (start.hour == 23 and end.hour == 0):
            mid = datetime(start.year, start.month, start.day, start.hour, 59, 59)
            start_mile = (mid - start).total_seconds() * n_mile / (end - start).total_seconds()
            start_earnings = (mid - start).total_seconds() * earnings / (end - start).total_seconds()
            
            key = ",".join([str(start.hour), datetime.strftime(start, date_fmt), driver])
            val = ",".join([datetime.strftime(start, dtime_fmt), datetime.strftime(mid, dtime_fmt), n_pass, 1, start_mile, start_earnings])
            print(key + "\t" + val)
            
            key = ",".join([str(end.hour), datetime.strftime(end, date_fmt), driver])
            val = ",".join([datetime.strftime(mid, dtime_fmt), datetime.strftime(end, dtime_fmt), 0, 0, n_mile - start_mile, earnings - start_earnings])
            print(key + "\t" + val)
        
        elif (end.hour == start.hour + 2) or (start.hour == 22 and end.hour == 0) or (start.hour == 23 and end.hour == 1):
            mid1 = datetime(start.year, start.month, start.day, start.hour, 59, 59)
            if start.hour == 23:
                mid2 = datetime(start.year, start.month, start.day, 0, 59, 59)
            else:
                mid2 = datetime(start.year, start.month, start.day, start.hour + 1, 59, 59)
            start_mile = (mid1 - start).total_seconds() * n_mile / (end - start).total_seconds()
            start_earnings = (mid1 - start).total_seconds() * earnings / (end - start).total_seconds()
            mid_mile = 3600 * n_mile / (end - start).total_seconds()
            mid_earnings = 3600 * earnings / (end - start).total_seconds()
            
            key = ",".join([str(start.hour), datetime.strftime(start, date_fmt), driver])
            val = ",".join([datetime.strftime(start, dtime_fmt), datetime.strftime(mid1, dtime_fmt), n_pass, 1, start_mile, start_earnings])
            print(key + "\t" + val)
            
            key = ",".join([str(mid2.hour), datetime.strftime(mid2, date_fmt), driver])
            val = ",".join([datetime.strftime(mid1, dtime_fmt), datetime.strftime(mid2, dtime_fmt), 0, 0, mid_mile, mid_earnings])
            print(key + "\t" + val)
            
            key = ",".join([str(end.hour), datetime.strftime(end, date_fmt), driver])
            val = ",".join([datetime.strftime(mid2, dtime_fmt), datetime.strftime(end, dtime_fmt), 0, 0, n_mile - (start_mile + mid_mile), earnings - (start_earnings + mid_earnings)])
            print(key + "\t" + val)
