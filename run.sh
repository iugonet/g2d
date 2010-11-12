#!/bin/bash

export RUBYLIB=.:$RUBYLIB

date

IMPORT_PID=`pgrep -u dspace -o run.sh`
echo $IMPORT_PID

if [ $$ = $IMPORT_PID ]; then
 rm -f update.out
 ruby main.rb >& i.out
 if [ -s FileStatus.out ]; then
   /opt/dspace/bin/index-update
 fi
 ./clean.sh
 cp update.out     /opt/dspace/webapps/iugonet/iugonet/.
else
 echo "PASS"
fi

date
