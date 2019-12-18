#!/usr/bin/env python3

# -*- coding: utf-8 -*-

# Sample Python code for youtube.search.list
# See instructions for running these code samples locally:
# https://developers.google.com/explorer-help/guides/code_samples#python

import os
import datetime
import rfc3339
import csv

import google_auth_oauthlib.flow
import googleapiclient.discovery
import googleapiclient.errors

scopes = ["https://www.googleapis.com/auth/youtube.force-ssl"]

def main():
    # Read the channel IDs
    channels = []
    with open('sponsored_channel_ids.csv') as csvfile:
        readCSV = csv.reader(csvfile, delimiter=',')
        for row in readCSV:
            channels.append(row[0])

    # Disable OAuthlib's HTTPS verification when running locally.
    # *DO NOT* leave this option enabled in production.
    os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"

    api_service_name = "youtube"
    api_version = "v3"
    client_secrets_file = "client_secret_7.json"

    # Get credentials and create an API client
    flow = google_auth_oauthlib.flow.InstalledAppFlow.from_client_secrets_file(
        client_secrets_file, scopes)
    credentials = flow.run_console()
    youtube = googleapiclient.discovery.build(
        api_service_name, api_version, credentials=credentials)

    # Categories to try: Videoblogging (21), People & Blogs (22), Entertainment (24),
    # Howto & Style (26)

    # # Break down the query by time:
    # delta = datetime.timedelta(days=50)
    # prevTime = datetime.datetime(2018,1,1,00,00,00)
    # publishTimes = [prevTime]

    # for i in range(1,100):
    #     newTime = prevTime + delta
    #     publishTimes.append(newTime)
    #     prevTime = newTime


    for i in range(len(channels)):
        request = youtube.search().list(
            part="snippet",
            maxResults=50,
            regionCode="US",
            channelId=channels[i],
            type="video"
        )
        response = request.execute()

        print(response)

        nextPageToken = response.get('nextPageToken')

        # for i in range(19999):
        while('nextPageToken' in response):
            response = youtube.search().list(
                part="snippet",
                maxResults=50,
                regionCode="US",
                channelId=channels[i],
                type="video",
                pageToken=nextPageToken
            ).execute()
            print(response)
            if('nextPageToken' in response):
                nextPageToken = response['nextPageToken']

if __name__ == "__main__":
    main()