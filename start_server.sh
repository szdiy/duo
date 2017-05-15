#!/bin/bash

echo "Remember to create the file szdiy/local_settings.py for the uwsgi server"
echo -e "Usage: ./start_server.sh <python_home>\n"

if [ $# -eq 0 ] 
then
    export PYTHON_HOME=/home/terryoy/.venv/szdiy-duo
else
    export PYTHON_HOME=$1
fi

echo "PYTHON_HOME=${PYTHON_HOME}"


# Uncomment below for port listening
#uwsgi --http :12001 --module szdiy.wsgi

# Uncomment below for unix socket
$PYTHON_HOME/bin/uwsgi \
    --vacuum \
    --master --pidfile=.pid_duo \
    --http :12001 \
    --socket szdiy-duo.sock \
    --module szdiy.wsgi -H $PYTHON_HOME \
    --daemonize=dev.log && echo "uwsgi started"




