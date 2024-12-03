#!/bin/sh

# This script automates the build of docker images.
# It generates images for datastore, oswm and opa with
# all the files for testing purpose.

## Datastore
echo "Building \"datastore\" docker image"

cp -r ./datas/ ../src/datastore
docker build -t datastore ../src/datastore
rm -rf ../src/datastore/datas

## Wrapper
echo "Building \"wrapper\" docker image"

cp -r ./policies/ ../src/wrapper
docker build -t wrapper ../src/wrapper
rm -rf ../src/wrapper/policies

## OPA
echo "Building \"opa\" docker image"

cp -r ./policies/ ./opa
docker build -f opa/Dockerfile -t opa .
rm -rf ./opa/policies

# Apache Benchmark
echo "Building \"apache\" docker image"

docker build -f apache/Dockerfile -t apache .