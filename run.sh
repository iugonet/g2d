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
 if [ -s update.out ]; then
   cp update.out /opt/dspace/webapps/iugonet/iugonet/.
   ruby util/ulist.rb
   cp update_list.html /opt/dspace/webapps/iugonet/iugonet/.
 fi
 date >> time.out
else
 echo "PASS"
fi

