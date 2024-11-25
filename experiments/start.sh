#!/bin/sh

# Read all the subdirectories and cycle for each of them
for dir in */; do
    echo "Starting experiment in directory ./$dir"

    ## Load policy for opa
    docker run -it --rm -p 8181:8181 -v ./${dir}policy.rego:/app/policy.rego openpolicyagent/opa run --server /app/policy.rego &&

    ## Load state for datastore
    docker build -t wosm/datastore ../datastore &&
    docker run -it --rm -p 8081:8081 wosm/datastore &&

    ## Load policy for opa-wrapper
    docker build -t wosm/wrapper ../opawrap &&
    docker run -it --rm -p 8080:8080 -v ./${dir}policy.rego:/app/policy.rego wosm/wrapper /app/policy.rego &&

    ## Launch apache bench 

    ## Save data inside a csv file
done

