#!/bin/sh

# This script automates the build of docker images.
# It generates images for datastore, oswm and opa with
# all the files for testing purpose.

EXPERIMENT="ex1"

## Datastore
echo "Building \"datastore\" docker image"

cp -r ./artifacts/datas/ ../src/datastore
docker build -t datastore ../src/datastore
docker save -o datastore.tar datastore
mv datastore.tar ./${EXPERIMENT}/images
rm -rf ../src/datastore/datas

## Wrapper
echo "Building \"wrapper\" docker image"

cp -r ./artifacts/policies/ ../src/wrapper
docker build -t wrapper ../src/wrapper
docker save -o wrapper.tar wrapper
mv wrapper.tar ./${EXPERIMENT}/images
rm -rf ../src/wrapper/policies

## OPA
echo "Building \"opa\" docker image"

cp -r ./artifacts/policies/ ./opa
cp -r ./artifacts/datas/ ./opa
docker build -t opa ./opa/
docker save -o opa.tar opa
mv opa.tar ./${EXPERIMENT}/images
rm -rf ./opa/datas
rm -rf ./opa/policies

# Tester
echo "Building \"tester\" docker image"

cp -r ./artifacts/inputs/ ./tester
docker build -t tester ./tester/
docker save -o tester.tar tester
mv tester.tar ./${EXPERIMENT}/images
rm -rf ./tester/inputs
