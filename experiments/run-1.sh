#!/bin/bash

set -ex

# define cleanup function
cleanup() {
  for pid in "${pids[@]}"; do
    kill -0 "$pid" && kill "$pid" # kill process only if it's still running
  done
}

# and set that function to run before we exit, or specifically when we get a SIGTERM
trap cleanup EXIT TERM

pids=( )
INDEXES=("1" "2" "3")
REQUESTS=("100" "200" "400" "800" "1600" "3200" "6400" "12800" "25600" "51200" "102400")
EXPERIMENTS=("exp-1") # "exp-2" "exp-3")
WRAPPER=wrapper-lock

for exp in "${EXPERIMENTS[@]}"; do
    echo "[INFO] [EXP:$exp] Running experiment $exp..."

    mkdir -p "./results/$exp/owsm"
    mkdir -p "./results/$exp/opa"

    for index in "${INDEXES[@]}"; do
    	echo "[INFO] [EXP:$exp] [UC:$index] Starting use case n.$index"

        ./datastore ./datas/data$index.json & pids+=( "$!" )

        ./opa run --server ./policies/policy$index.rego ./datas/data$index.json & pids+=( "$!" )

        ./$WRAPPER ./policies/policy$index.rego & pids+=( "$!" )

        for request in "${REQUESTS[@]}"; do
          ./ab -n $request -c 1 -T application/json -p ./inputs/input$index.json -g ./results/$exp/owsm/$index-$request.tsv http://localhost:8080/query
          ./ab -n $request -c 1 -T application/json -p ./inputs/input$index.json -g ./results/$exp/opa/$index-$request.tsv http://localhost:8181/v1/data/examplerego
        done

        echo "[INFO] [EXP:$exp] [UC:$index] Use case n.$index complete!"
    done

    echo "[INFO] [EXP:$exp] Experiment $exp complete!"
done
