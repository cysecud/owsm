#!/bin/sh
DATASTORE_URL="localhost"
DATASTORE_PORT="8081"

WRAPPER_URL="localhost"
WRAPPER_PORT="8080"

# Put a_to_b = false to datastore

echo "Setting datastore..."
curl -X PUT --header 'Content-Type: application/json' --data-raw 'false' http://"${DATASTORE_URL}":"${DATASTORE_PORT}"/data/a_to_b
curl -X GET "http://${DATASTORE_URL}:${DATASTORE_PORT}/data"
echo "\n"

# B starts to communicate with C

echo "Since {\"a_to_b\":false}, B and C can communicate as much as they want..."
for i in 1 2 3 4 5
do 
    curl -X POST --header 'Content-Type: application/json' --data-raw "{\"source\":\"b\", \"dest\":\"c\"}" "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
    echo "\r"
done
echo "The value of \"a_to_b\" was untouched..."
curl -X GET "http://${DATASTORE_URL}:${DATASTORE_PORT}/data"
echo "\n"

# A starts to communicate with B

echo "At some point A starts to communicate with B"
curl -X POST --header 'Content-Type: application/json' --data-raw "{\"source\":\"a\", \"dest\":\"b\"}" "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
echo "\r"
echo "The comunication is allowed and \"a_to_b\" becomes true"
curl -X GET "http://${DATASTORE_URL}:${DATASTORE_PORT}/data"
echo "\r"
echo "A can communicate with B as many times as it wants..."
for i in 1 2 3
do 
    curl -X POST --header 'Content-Type: application/json' --data-raw "{\"source\":\"a\", \"dest\":\"b\"}" "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
    echo "\r"
done
echo "\n"

# From now on, B can no longer communicate with C

echo "From now on, B can no longer communicate with C"
echo "As a matter of fact, if B wants to communicate with C..."
curl -X POST --header 'Content-Type: application/json' --data-raw "{\"source\":\"b\", \"dest\":\"c\"}" "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
echo "\r"