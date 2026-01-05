#!/bin/sh
DATASTORE_URL="localhost"
DATASTORE_PORT="8081"

WRAPPER_URL="localhost"
WRAPPER_PORT="8080"

echo "Can B comunicate with C?"
curl -v -X POST --header 'Content-Type: application/json' --data-raw '{"source": "b", "dest": "c"}' "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
echo "\n"

echo "Now A comuncates with B"
curl -v -X POST --header 'Content-Type: application/json' --data-raw '{"source": "a", "dest": "b"}' "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
echo "\n"

echo "Can B still comunicate with C?"
curl -v -X POST --header 'Content-Type: application/json' --data-raw '{"source": "b", "dest": "c"}' "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
echo "\n"

echo "Can B still comunicate with C?"
curl -v -X POST --header 'Content-Type: application/json' --data-raw '{"source": "b", "dest": "c"}' "http://${WRAPPER_URL}:${WRAPPER_PORT}/query"
echo "\n"