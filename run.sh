#!/bin/bash

export RUBYLIB=.:$RUBYLIB


IMPORT_PID=`pgrep -u dspace -o run.sh`

if [ $$ = $IMPORT_PID ]; then
 echo $IMPORT_PID > time.out
 date >> time.out
 rm -f update.out
 ruby main.rb >& i.out
 if [ -s FileStatus.log ]; then
   /opt/dspace/bin/index-update
 fi
 ./clean.sh
 cp update.out /opt/dspace/webapps/iugonet/iugonet/.
 date >> time.out
else
 echo "PASS"
fi

