#!/bin/bash

set -ex

############################
# Cleanup handling
############################
pids=()

cleanup() {
  for pid in "${pids[@]}"; do
    kill -0 "$pid" 2>/dev/null && kill "$pid"
  done
}
trap cleanup EXIT TERM

############################
# Common configuration
############################
INDEXES=("1" "2" "3")
WRAPPER="wrapper-lock"

BASE_RESULTS="./results"

############################
# Experiment configurations
############################

# Experiment 1: vary number of requests
EXP1_NAME="exp-1"
EXP1_REQUESTS=("100" "200" "400" "800" "1600" "3200" "6400" "12800" "25600" "51200" "102400")

# Experiment 2: vary concurrency
EXP2_NAME="exp-2"
EXP2_CONCURRENCIES=("100" "200" "400" "800" "1600" "3200" "6400")
EXP2_REQUESTS=51200

############################
# Helper functions
############################

start_services() {
  local index="$1"

  ./datastore "./artifacts/datas/data${index}.json" & pids+=( "$!" )
  ./opa run --server "./artifacts/policies/policy${index}.rego" "./artifacts/datas/data${index}.json" & pids+=( "$!" )
  ./"$WRAPPER" "./artifacts/policies/policy${index}.rego" & pids+=( "$!" )
}

run_ab() {
  local requests="$1"
  local concurrency="$2"
  local index="$3"
  local exp="$4"

  ./ab -n "$requests" -c "$concurrency" \
    -T application/json \
    -p "./artifacts/inputs/input${index}.json" \
    -g "${BASE_RESULTS}/${exp}/owsm/${index}-${requests:-$concurrency}.tsv" \
    http://localhost:8080/query

  ./ab -n "$requests" -c "$concurrency" \
    -T application/json \
    -p "./artifacts/inputs/input${index}.json" \
    -g "${BASE_RESULTS}/${exp}/opa/${index}-${requests:-$concurrency}.tsv" \
    http://localhost:8181/v1/data/examplerego
}

############################
# Experiment 1
############################
echo "[INFO] Running experiment ${EXP1_NAME}"
mkdir -p "${BASE_RESULTS}/${EXP1_NAME}/owsm" "${BASE_RESULTS}/${EXP1_NAME}/opa"

for index in "${INDEXES[@]}"; do
  echo "[INFO] [EXP:${EXP1_NAME}] [UC:${index}] Starting use case"

  start_services "$index"

  for req in "${EXP1_REQUESTS[@]}"; do
    run_ab "$req" 1 "$index" "$EXP1_NAME"
  done

  echo "[INFO] [EXP:${EXP1_NAME}] [UC:${index}] Complete"
done

############################
# Experiment 2
############################
echo "[INFO] Running experiment ${EXP2_NAME}"
mkdir -p "${BASE_RESULTS}/${EXP2_NAME}/owsm" "${BASE_RESULTS}/${EXP2_NAME}/opa"

for index in "${INDEXES[@]}"; do
  echo "[INFO] [EXP:${EXP2_NAME}] [UC:${index}] Starting use case"

  start_services "$index"

  for conc in "${EXP2_CONCURRENCIES[@]}"; do
    run_ab "$EXP2_REQUESTS" "$conc" "$index" "$EXP2_NAME"
  done

  echo "[INFO] [EXP:${EXP2_NAME}] [UC:${index}] Complete"
done

echo "[INFO] All experiments completed!"
