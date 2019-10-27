#!/usr/bin/env python3
"""
Step 5: map

"""


import sys

def main():
	"""
	key:= data,hour
	value:= t_onduty,t_occupied,n_pass,n_trip,n_mile,earnings
	"""

	for line in sys.stdin:
		params = line.strip().split('\t')
		key = ",".join([params[0], params[1]])
		val = ",".join(params[3:])
		print(key + "\t" + val)



if __name__ == "__main__":
    main()