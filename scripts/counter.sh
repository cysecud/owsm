#!/bin/sh
DATASTORE_URL="localhost"
DATASTORE_PORT="8081"

WRAPPER_URL="localhost"
WRAPPER_PORT="8080"

curl -X PUT --header 'Content-Type: application/json' --data-raw '5' "http://${DATASTORE_URL}:${DATASTORE_PORT}/data/counter"
curl -X GET "http://${DATASTORE_URL}:${DATASTORE_PORT}/data"
echo "\r"

for i in 1 2 3 4 5 6
do 
    curl -X POST --header 'Content-Type: application/json' --data-raw "{\"user\":\"fabio\"}" "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
    echo "\r"
done