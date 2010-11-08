#!/bin/bash

export RUBYLIB=.:$RUBYLIB

IMPORT_PID=`pgrep -u dspace -o run.sh`
echo $IMPORT_PID

if [ $$ = $IMPORT_PID ]; then
 ruby main.rb >& i.out
 if [ -s FileStatus.log ]; then
   /opt/dspace/bin/index-update
 fi
 ./clean.sh
else
 echo "PASS"
fi
