#!/usr/bin/env python3

#!/usr/bin/env python3

import sys
import nltk
import datetime



def main():
	for line in sys.stdin:
		params = line.strip().split('\t')
		
		date=params[1]
		text = params[2]
		lengthTweet = str(len(text))
		startQuoteAt = "1" if text[0:2] == "\"@" else "0"
		startQuote = "1" if text[0] == "\"" else "0"
		tweet_tokens = nltk.tokenize.word_tokenize(text)

		date=date.replace("T"," ")
		date=date.replace("Z","")
		day=date.split(" ")[0]
		time=date.split(" ")[1]

		# get weekday
		year, month, day = (int(x) for x in day.split('-'))    
		wkday = datetime.date(year, month, day).weekday()
		if wkday == 0:
		    wkday="monday"
		if wkday == 1:
		    wkday="tuesday"
		if wkday == 2:
		    wkday="wednesday"
		if wkday == 3:
		    wkday="thursday"
		if wkday == 4:
		    wkday="friday"
		if wkday == 5:
		    wkday="saturday"
		if wkday == 6:
		    wkday="sunday"



		# get time bucket
		bucket="unknown"
		if '02:00:00' <= time <= '07:00:00':
		    bucket="night"
		if '07:00:00' <= time <= '12:00:00':
		    bucket="morning"
		if '12:00:00' <= time <= '17:00:00':
		    bucket="afternoon"
		if '17:00:00' <= time <= '22:00:00':
		    bucket="evening"
		if ('22:00:00' <= time <= '23:59:59' or '00:00:00' <= time < '02:00:00'):
		    bucket="late_evening"

		# get number of upper case characters
		text=params[2]
		count_upper=0
		for i in text:
		      if(i.isupper()):
		            count_upper=count_upper+1
		            
		pct_upper=count_upper/len(text)

		# get number of uppercase words
		count_allcaps=sum(map(str.isupper, text.split()))
		nwords=len(text.split())
		pct_allcaps=count_allcaps/nwords

		# get number of all caps after removing the three first letters
		def remove_cruft(s):
		    return s[3:len(s)]

		vec=[remove_cruft(s) for s in text.split()]
		count_m3=sum(map(str.isupper, vec))
		allcaps="0"
		if count_m3>=1:
		    allcaps="1"

		# Maybe we have to introduce the values in []?
		print("date " + wkday + " " + bucket + " |" + "Caps " + allcaps + " |" + "Length " + lengthTweet +
		 " |" + "Quote " + startQuote + " |" + "QuoteAt " + startQuoteAt + " |" + "Tweet " + " ".join(tweet_tokens))



if __name__ == "__main__":
    main()