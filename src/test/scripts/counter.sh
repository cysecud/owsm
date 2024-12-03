#!/bin/sh
DATASTORE_URL="localhost"
DATASTORE_PORT="8081"

WRAPPER_URL="localhost"
WRAPPER_PORT="8080"

# Put counter = 5 to datastore

echo "Setting datastore..."
curl -X PUT --header 'Content-Type: application/json' --data-raw '5' http://"${DATASTORE_URL}":"${DATASTORE_PORT}"/data/counter
curl -X GET "http://${DATASTORE_URL}:${DATASTORE_PORT}/data"
echo "\n"

# the user fabio can make at most 5 queries
echo "From now on, we expect that the user fabio is allowed at most 5 times..."
for i in 1 2 3 4 5 6
do 
    curl -X POST --header 'Content-Type: application/json' --data-raw "{\"user\":\"fabio\"}" "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
    echo "\r"
done
echo "As a matter of fact, the sixth time access was denied"