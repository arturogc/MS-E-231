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
	
	if len(params) == 14: # trip data
        key = ",".join([line_data[0],line_data[1],line_data[5]])
    elif len(line_data) == 11: # fare data
        key = ",".join([line_data[0],line_data[1],line_data[3]])
    else:
            key = "NA" # this get checked and thrown out in the
