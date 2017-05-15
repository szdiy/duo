#!/bin/bash

echo "Remember to create the file szdiy/local_settings.py for the uwsgi server"
echo "Usage: ./start_server.sh <python_home>"

if [ $# -lt 0 ] 
then
    export PYTHON_HOME=$1
else
    export PYTHON_HOME=/home/terryoy/.venv/szdiy-duo
fi

echo "PYTHON_HOME=${PYTHON_HOME} PARAMETER=${1}"


# Uncomment below for port listening
#uwsgi --http :12001 --module szdiy.wsgi

# Uncomment below for unix socket
uwsgi --socket szdiy-duo.sock --module szdiy.wsgi -H $PYTHON_HOME

echo $! > .pid_duo



