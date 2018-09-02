#!/bin/bash
parse_data=$(curl -s "http://192.168.111.11:31141/helloworld/helloworld.json" | jq -r '.message' | rev)
echo $parse_data
