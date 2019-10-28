#!/usr/bin/env python3
"""
Created on Wed Oct 16 17:32:45 2019

@author: Lucas
"""

import sys
from datetime import datetime, timedelta


dtime_fmt = '%Y-%m-%d %H:%M:%S'
date_fmt = '%Y-%m-%d'

delta = timedelta(seconds=1)

index = {'hack' : 1,
         'start' : 5,
         'end' : 6,
         'pass' : 7,
         'mile' : 9,
         'earnings' : 20}


def main():
    for line in sys.stdin:
        line = line.strip().split('\t')
        
        driver = line[index['hack']]
        start = datetime.strptime(line[index['start']], dtime_fmt)
        end = datetime.strptime(line[index['end']], dtime_fmt)
        n_pass = int(line[index['pass']])
        n_mile = float(line[index['mile']])
        earnings = float(line[index['earnings']])
        
        if start.hour == end.hour:
            key = ",".join([datetime.strftime(start, date_fmt), str(start.hour), driver])
            val = ",".join([datetime.strftime(start, dtime_fmt), datetime.strftime(end, dtime_fmt), str(n_pass), "1", str(n_mile), str(earnings)])
            print(key + "\t" + val)
        
        elif (end.hour == start.hour + 1) or (start.hour == 23 and end.hour == 0):
            # trip spans over two hours - need to break it in two lines
            
            mid = datetime(start.year, start.month, start.day, start.hour, 59, 59)
            start_mile = (mid - start).total_seconds() * n_mile / (end - start).total_seconds()
            start_earnings = (mid - start).total_seconds() * earnings / (end - start).total_seconds()
            
            key = ",".join([datetime.strftime(start, date_fmt), str(start.hour), driver])
            val = ",".join([datetime.strftime(start, dtime_fmt), datetime.strftime(mid, dtime_fmt), str(n_pass), "1", str(start_mile), str(start_earnings)])
            print(key + "\t" + val)
            
            key = ",".join([datetime.strftime(end, date_fmt), str(end.hour), driver])
            val = ",".join([datetime.strftime(mid + delta, dtime_fmt), datetime.strftime(end, dtime_fmt), "0", "0", str(n_mile - start_mile), str(earnings - start_earnings)])
            print(key + "\t" + val)
        
        elif (end.hour == start.hour + 2) or (start.hour == 22 and end.hour == 0) or (start.hour == 23 and end.hour == 1):
            # trip spans over three hours - need to break it in three lines
            
            mid1 = datetime(start.year, start.month, start.day, start.hour, 59, 59)
            if start.hour == 23:
                mid2 = datetime(start.year, start.month, start.day, 0, 59, 59)
                mid2 = mid2 + timedelta(days=1)
            else:
                mid2 = datetime(start.year, start.month, start.day, start.hour + 1, 59, 59)
            start_mile = (mid1 - start).total_seconds() * n_mile / (end - start).total_seconds()
            start_earnings = (mid1 - start).total_seconds() * earnings / (end - start).total_seconds()
            mid_mile = 3600 * n_mile / (end - start).total_seconds()
            mid_earnings = 3600 * earnings / (end - start).total_seconds()
            
            key = ",".join([datetime.strftime(start, date_fmt), str(start.hour), driver])
            val = ",".join([datetime.strftime(start, dtime_fmt), datetime.strftime(mid1, dtime_fmt), str(n_pass), "1", str(start_mile), str(start_earnings)])
            print(key + "\t" + val)
            
            key = ",".join([datetime.strftime(mid2, date_fmt), str(mid2.hour), driver])
            val = ",".join([datetime.strftime(mid1 + delta, dtime_fmt), datetime.strftime(mid2, dtime_fmt), "0", "0", str(mid_mile), str(mid_earnings)])
            print(key + "\t" + val)
            
            key = ",".join([datetime.strftime(end, date_fmt), str(end.hour), driver])
            val = ",".join([datetime.strftime(mid2 + delta, dtime_fmt), datetime.strftime(end, dtime_fmt), "0", "0", str(n_mile - (start_mile + mid_mile)), str(earnings - (start_earnings + mid_earnings))])
            print(key + "\t" + val)
        
        else:
            # trip spans on more than three hours - assume it's erroneous data
            pass


if __name__ == "__main__":
    main()
