#!/usr/bin/env python3

# -*- coding: utf-8 -*-

# Sample Python code for youtube.videos.list
# See instructions for running these code samples locally:
# https://developers.google.com/explorer-help/guides/code_samples#python

import sys
import os

import google_auth_oauthlib.flow
import googleapiclient.discovery
import googleapiclient.errors

scopes = ["https://www.googleapis.com/auth/youtube.readonly"]

def main():
    # Read the IDs
    videoIDs = open("id22Full.txt","r").read()
    # We can only request 50 at a time. Compute number of groups of 50 IDs:
    # Each ID has 11 characters. For 50 IDs: 550 char + 50 commas = 600
    num = len(videoIDs) // 600 + 1

    # Disable OAuthlib's HTTPS verification when running locally.
    # *DO NOT* leave this option enabled in production.
    os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"

    api_service_name = "youtube"
    api_version = "v3"
    client_secrets_file = "client_secret_8.json"

    # Get credentials and create an API client
    flow = google_auth_oauthlib.flow.InstalledAppFlow.from_client_secrets_file(
        client_secrets_file, scopes)
    credentials = flow.run_console()
    youtube = googleapiclient.discovery.build(
        api_service_name, api_version, credentials=credentials)

    for i in range(num):
        request = youtube.videos().list(
            part="snippet,contentDetails,statistics",
            id = videoIDs[(600*i):(600*(i+1)-1)]
        )
        response = request.execute()

        print(response)

if __name__ == "__main__":
    main()
