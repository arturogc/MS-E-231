# Step 3
# Map step

import sys

"""

For each line of data, it emits the following (key,value) pais:
    - Key: medallion,starttime
    - Value: line

"""

for line in sys.stdin:
	# We input the first line
	params = line.strip().split(,)

	
	# The line may be from either table (fares.csv or trip.csv), so we have to identify it:
	if len(params) == 14: # trip data
        key = ",".join([params[0],params[1],params[5]])
    elif len(params) == 11: # fare data
        key = ",".join([params[0],params[1],params[3]])
    else:
        key = "NA" # this get checked and thrown out in the

    # If it is the header, we get rid of it (not needed for the reduce step)
    if key[0].isdigit():
        print(key + "\t" + line.strip())
    else:
        pass
