#!/bin/bash
####AURTHOR AVINASH SINGH ######################################
######02092018##################################################
############Parse Data ###########################################
parse_data=$(curl -s "http://tomcat-one:8080/app/helloworld.json" | jq -r '.message' | rev)
############Parse Data and Put in file inside application ########
cat >/var/www/app/reversehellowold.json <<EOL
{
"id": "1",
"message": "$parse_data"
}
EOL
