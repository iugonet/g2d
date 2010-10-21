#!/bin/bash

export RUBYLIB=.:$RUBYLIB

ruby main.rb >& i.out
./clean.sh

