#!/bin/bash

echo "[INFO] Loading docker images..."
for image in "images"/*; do
    docker load < $image
done

INDEXES=("1" "2" "3")
for index in "${INDEXES[@]}"; do
    echo "[INFO] Running experiment on use case n.$index"
    printf "POLICY_NAME=\"policy$index.rego\"\nDATA_NAME=\"data$index.json\"\nINPUT_NAME=\"input$index.json\"" > .env
    docker compose up -d

    # Loop until the file exists
    while [ ! -f "./results/.done" ]; do
        sleep 1  # Wait 5 seconds before checking again
    done

    docker compose stop
    rm .env ./results/.done
    echo "[INFO] Experiment on use case n.$index complete!"
done
