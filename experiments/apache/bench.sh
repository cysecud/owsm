#!/bin/bash

INPUT=$INPUT_NAME
outputFile="/app/results/result-$INPUT.csv"
echo "requests,owsm_avg_time_ms,opa_avg_time_ms" > $outputFile

owsm_URL="http://wrapper:8080/query"
opa_URL="http://opa:8181/v1/data/examplerego"

numRequests=(100 200 400 800 1600 3200 6400 12800 25600 51200)
c=1

function tprExtract() {
   local result="$1"
   echo "$result" | grep "Time per request:" | head -n 1 | awk '{print $4}'
}

echo "[INFO] Starting benchmark with $INPUT_NAME"

for r in "${numRequests[@]}"; do
   owsm_result=$(ab -n $r -c $c -p /app/$INPUT_NAME -T application/json $owsm_URL)
   owsm_avg_time_ms=$(tprExtract "$owsm_result")

   opa_result=$(ab -n $r -c $c -p /app/$INPUT_NAME -T application/json $opa_URL)
   opa_avg_time_ms=$(tprExtract "$opa_result")

   echo "$r,$owsm_avg_time_ms,$opa_avg_time_ms" >> $outputFile
done

echo "[INFO] Complete benchmark for $INPUT_NAME"
echo "" > /app/results/.done
