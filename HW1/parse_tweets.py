# -*- coding: utf-8 -*-
"""
Created on Fri Oct  4 17:34:12 2019

@author: Lucas Lesniewski
"""

import sys
import json
import datetime
import csv


def round(dtime, interval=15):
    """
    Rounds a datetime object to the nearest time interval (in minutes).
    """
    rounded_minutes = (dtime.minute + interval / 2) // interval * interval
    return dtime + datetime.timedelta(minutes=rounded_minutes - dtime.minute)


def parse_datetime(line):
    """
    From a JSON Tweet object, returns a datetime object representing when the 
    Tweet was created.
    """
    info = line['created_at'] # extracting relevant information
    MONTHS = {'Oct': 10} # month-to-number mapping dictionary
    
    year = info[26:]
    month = MONTHS[info[4:7]]
    day = info[8:10]
    hour = info[11:13]
    minute = info[14:16]
    
    return datetime.datetime(year=int(year), month=int(month), day=int(day), 
                    hour=int(hour), minute=int(minute))


def isEnglish(s):
    """
    Checks if a string is composed entirely of ASCII characters.
    """
    try:
        s.encode('ascii')
    except UnicodeEncodeError:
        return False
    return True


def parse(line):
    """
    From a JSON Tweet object, returns a list containing the following 
    information:
        (1) date (UTC Time)
        (2) time rounded to the nearest 15-minute interval (UTC Time)
        (3) the name of the user
        (4) the name of the original poster, if the Tweet is a 
        Retweet (otherwise 'NA').
    """
    dtime = parse_datetime(line)
    dtime = round(dtime, interval=15)
    date = dtime.date().strftime('%Y-%m-%d') # format is arbitrary
    time = dtime.time().strftime('%H:%M') # format is arbitrary
    
    user = line['user']['name']
    if not isEnglish(user):
        raise KeyError # pass on this Tweet
    
    try:
        original = line['retweeted_status']['user']['name']
        if not isEnglish(original):
            raise KeyError # pass on this Tweet
    except KeyError:
        original = 'NA'
    
    return [date, time, user, original]


if __name__ == '__main__':
    
    # create stream of Tweets as input
    if len(sys.argv) > 1:
        line_generator = open(sys.argv[1])
    else:
        line_generator = sys.stdin
    
    # create output file
    with open('data.csv', 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quotechar='"',
                            quoting=csv.QUOTE_MINIMAL)
        
        # parse Tweets
        for line in line_generator:
            line = json.loads(line)
            try:
                data = parse(line)
                print(data) # for tracking purposes
                writer.writerow(data)
            except KeyError:
                pass
