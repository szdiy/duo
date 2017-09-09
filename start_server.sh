#!/bin/bash

echo "Remember to create the file szdiy/local_settings.py for the uwsgi server"
echo "Create settings:"
echo "$ ln -s szdiy/settings.py szdiy/local_settings.py"
echo ""
echo "Start server:"
echo -e "$ ./start_server.sh <python_home>\n"

if [ $# -gt 0 ] 
then
    export PYTHON_HOME=$1
else
    export PYTHON_HOME=/home/terryoy/.venv/szdiy-duo
fi

echo "PYTHON_HOME=${PYTHON_HOME} PARAMETER=${1}"


# Uncomment below for port listening
#uwsgi --http :12001 --module szdiy.wsgi

# Uncomment below for unix socket
$PYTHON_HOME/bin/uwsgi \
    --vacuum \
    --master --pidfile=.pid_duo \
    --http :12001 \
    --socket szdiy-duo.sock \
    --module szdiy.wsgi -H $PYTHON_HOME \
    --daemonize=/var/log/uwsgi/szdiy-duo/dev.log && echo "uwsgi started"




