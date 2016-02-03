#!/bin/sh
#
# create the docker machine
docker-machine create --driver "virtualbox" default

# start the docker machine
docker-machine start default

# this command allows the docker commands to be used in the terminal
eval "$(docker-machine env default)"
