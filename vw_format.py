#!/usr/bin/env python3

import sys
import nltk
import datetime
import codecs

WEEKDAY_DIC = {0: "monday", 1: "tuesday", 2: "wednesday", 3: "thursday", 4: "friday", 5: "saturday", 6: "sunday"}


def time_bucket(time):
	"""
	Converts time string into string indicating the corresponding period of the day.
	"""
	if '00:00:00' <= time < '02:00:00':
		return "late_evening"
	elif time <= '07:00:00':
		return "night"
	elif time <= '12:00:00':
		return "morning"
	elif time <= '17:00:00':
		return "afternoon"
	elif time <= '22:00:00':
		return "evening"
	else:
		return "late_evening"


def main():
	for line in codecs.getreader('utf8')(sys.stdin.detach(), errors='ignore'):
		line.encode("utf-8")
		params = line.strip().split('\t')

		date = params[1]
		text = params[2]
		length_tweet = str(len(text))
		start_quote = "1" if text[0] == "\"" else "0"
		start_quote_at = "1" if text[0:2] == "\"@" else "0"
		tweet_tokens = nltk.tokenize.word_tokenize(text)

		date = date.replace("T", " ")
		date = date.replace("Z", "")
		day, time = date.split(" ")[0], date.split(" ")[1]

		# get weekday
		year, month, day = (int(x) for x in day.split('-'))
		weekday = datetime.date(year, month, day).weekday()
		weekday = WEEKDAY_DIC[weekday]

		# get time bucket
		bucket = time_bucket(time)

		# get number of upper case characters
		text = params[2]
		count_upper = 0
		for i in text:
			if i.isupper():
				count_upper += 1

		pct_upper = count_upper/len(text)

		# get number of uppercase words
		count_allcaps = sum(map(str.isupper, text.split()))
		nwords = len(text.split())
		pct_allcaps = count_allcaps/nwords

		# get number of all caps after removing the three first letters
		def remove_cruft(s):
			return s[3:len(s)]

		vec=[remove_cruft(s) for s in text.split()]
		count_m3=sum(map(str.isupper, vec))
		allcaps = "0"
		if count_m3 >= 1:
			allcaps = "1"

		# Maybe we have to introduce the values in []?
		print("date " + weekday + " " + bucket + " |" + "Caps " + allcaps + " |" + "Length " + length_tweet +\
		" |" + "Quote " + start_quote + " |" + "QuoteAt " + start_quote_at + " |" + "Tweet " +\
		" ".join(tweet_tokens))


if __name__ == "__main__":
	main()
