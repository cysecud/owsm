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
EXPERIMENTS=("ex1") # "ex2" "ex3")

for exp in "${EXPERIMENTS[@]}"; do
    echo "[INFO] [EXP:$exp] Running experiment $exp..."

    for index in "${INDEXES[@]}"; do
    	echo "[INFO] [EXP:$exp] [UC:$index] Starting use case n.$index"

        ./datastore ./datas/data$index.json & pids+=( "$!" )

        ./opa run --server ./policies/policy$index.rego ./datas/data$index.json & pids+=( "$!" )

        ./wrapper ./policies/policy$index.rego & pids+=( "$!" )

        #USE_CASE=$index ./tester ./inputs/input$index.json & pids+=( "$!" )


	./ab -n 10000 -c 1 -T application/json -p ./inputs/input$index.json -g ./results/$exp/owsm/$index-c1.tsv http://localhost:8080/query
	./ab -n 10000 -c 10 -T application/json -p ./inputs/input$index.json -g ./results/$exp/owsm/$index-c10.tsv http://localhost:8080/query
	./ab -n 10000 -c 100 -T application/json -p ./inputs/input$index.json -g ./results/$exp/owsm/$index-c100.tsv http://localhost:8080/query
	./ab -n 10000 -c 1000 -T application/json -p ./inputs/input$index.json -g ./results/$exp/owsm/$index-c1000.tsv http://localhost:8080/query

	./ab -n 10000 -c 1 -T application/json -p ./inputs/input$index.json -g ./results/$exp/opa/$index-c1.tsv http://localhost:8181/v1/data/examplerego
	./ab -n 10000 -c 10 -T application/json -p ./inputs/input$index.json -g ./results/$exp/opa/$index-c10.tsv http://localhost:8181/v1/data/examplerego
	./ab -n 10000 -c 100 -T application/json -p ./inputs/input$index.json -g ./results/$exp/opa/$index-c100.tsv http://localhost:8181/v1/data/examplerego
	./ab -n 10000 -c 1000 -T application/json -p ./inputs/input$index.json -g ./results/$exp/opa/$index-c1000.tsv http://localhost:8181/v1/data/examplerego

        # Loop until the file exists
        # while [ ! -f "./results/.done" ]; do
            # sleep 1
        #done

		#rm "./results/.done"
        echo "[INFO] [EXP:$exp] [UC:$index] Use case n.$index complete!"
    done

    #rm .env
    echo "[INFO] [EXP:$exp] Experiment $exp complete!"
done
