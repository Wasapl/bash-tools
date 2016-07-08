#!/bin/bash

#Modify these variables for your environment
MY_HOSTNAME="local"
SLACK_BOTNAME="WASAbot"

ICON=":exclamation:"

text=$@
#Send message to Slack
curl -X POST --data "payload={ \"username\": \"${SLACK_BOTNAME}\", \"text\": \"${ICON} HOST:${MY_HOSTNAME}\n${text}\"}" \
     <Provide your own webhook URL here e.g. https://hooks.slack.com/services/xxxxxx/xxxxxxx/xxxxxxxxx>

