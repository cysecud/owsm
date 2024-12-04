#!/bin/bash

INPUT=$INPUT_NAME
outputFile="/app/results/result-$INPUT.csv"
echo "requests,owsm_avg_time_ms,opa_avg_time_ms" > $outputFile

owsm_URL="http://wrapper:8080/query"
opa_URL="http://opa:8181/v1/data/examplerego"

numRequests=2000
concurrency=(10 20 30 40 50 60 70 80 90 100)

function tprExtract() {
   local result="$1"
   echo "$result" | grep "Time per request:" | head -n 1 | awk '{print $4}'
}

echo "[INFO] Starting benchmark with $INPUT_NAME"

for c in "${concurrency[@]}"; do
   owsm_result=$(ab -numRequests $r -c $c -p /app/$INPUT_NAME -T application/json $owsm_URL)
   owsm_avg_time_ms=$(tprExtract "$owsm_result")

   opa_result=$(ab -numRequests $r -c $c -p /app/$INPUT_NAME -T application/json $opa_URL)
   opa_avg_time_ms=$(tprExtract "$opa_result")

   echo "$c,$owsm_avg_time_ms,$opa_avg_time_ms" >> $outputFile
done

echo "[INFO] Complete benchmark for $INPUT_NAME"
echo "" > /app/results/.done
