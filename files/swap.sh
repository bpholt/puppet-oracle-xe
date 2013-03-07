#!/bin/sh

SWAP=`grep SwapTotal /proc/meminfo | sed 's/[^0-9]//g'`
TOTAL=`grep MemTotal /proc/meminfo | sed 's/[^0-9]//g'`

GLOBAL_MIN_SWAP=2097152
RAM_MIN_SWAP=$[TOTAL*2]

if [ "$SWAP" -lt "$GLOBAL_MIN_SWAP" ]
then
  if [ "$SWAP" -lt "$RAM_MIN_SWAP" ]
  then
    if [ "$RAM_MIN_SWAP" -lt "$GLOBAL_MIN_SWAP" ]
    then
      echo "make $RAM_MIN_SWAP swap"
    else
      echo "make 2GB swap"
    fi
  fi
fi
