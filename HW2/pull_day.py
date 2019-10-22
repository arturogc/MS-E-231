# -*- coding: utf-8 -*-
"""
Created on Wed Oct 16 16:31:31 2019

@author: Lucas
"""

import sys
import csv


if __name__ == '__main__':
    
    day = sys.argv[1]  # e.g. '2013-01-01'
    filename = sys.argv[2]  # e.g. 'trip.csv'

    # create output file
    with open(filename, 'w', newline='') as csvfile:
        writer = csv.writer(csvfile, delimiter=',', quotechar='"',
                            quoting=csv.QUOTE_MINIMAL)
        
        for place, line in enumerate(sys.stdin):
            if place == 0:
                writer.writerow(line.strip().split(','))
            if day in line:
                writer.writerow(line.strip().split(','))
