#!/bin/bash

INDEXES=("1" "2" "3")
EXPERIMENTS=("ex1" "ex2" "ex3")
for exp in "${EXPERIMENTS[@]}"; do
    echo "[INFO] [EXP:$exp] Running experiment $exp..."
    for index in "${INDEXES[@]}"; do

        echo "[INFO] Loading docker images..."
        for image in "$exp/images"/*; do
            docker load < $image
        done

        echo "[INFO] [EXP:$exp] [UC:$index] Starting use case n.$index"
        printf "EXPERIMENT=\"$exp\"\nUSE_CASE=\"$index\"\nPOLICY_NAME=\"policy$index.rego\"\nDATA_NAME=\"data$index.json\"\nINPUT_NAME=\"input$index.json\"" > .env
        docker compose up -d

        # Loop until the file exists
        while [ ! -f "$exp/results/.done" ]; do
            sleep 1
        done

        docker compose down
        docker rmi -f $(docker images -aq)
        rm $exp/results/.done
        echo "[INFO] [EXP:$exp] [UC:$index] Use case n.$index complete!"
    done
    rm .env
    echo "[INFO] [EXP:$exp] Experiment $exp complete!"
done
