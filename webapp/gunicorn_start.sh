#!/bin/bash

NAME="Datacanvas-App"
APPDIR=/home/centos/projects/datacanvas/webapp
SOCKFILE=/home/centos/www/sock
NUM_WORKERS=3

echo "Starting $NAME"

# activate the virtualenv
source activate datacanvas

export PYTHONPATH=$APPDIR:$PYTHONPATH

# Create the run directory if it doesn't exist
RUNDIR=$(dirname $SOCKFILE)
test -d $RUNDIR || mkdir -p $RUNDIR

# Start your unicorn
exec gunicorn run:application -b 127.0.0.1:8001 \
  --name $NAME \
  --workers $NUM_WORKERS \
  --log-level=debug \
  --bind=unix:$SOCKFILE
