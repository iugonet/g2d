#!/bin/bash

export RUBYLIB=.:$RUBYLIB

date
pwd

IMPORT_PID=`pgrep -u dspace -o run.sh`
echo $IMPORT_PID

if [ $$ = $IMPORT_PID ]; then
 ruby main.rb >& i.out
 if [ -s FileStatus.out ]; then
   /opt/dspace/bin/index-update
 fi
  ./clean.sh
else
 echo "PASS"
fi

date
cp i.out          /opt/dspace/webapps/iugonet/iugonet/.
cp FileStatus.out /opt/dspace/webapps/iugonet/iugonet/.

