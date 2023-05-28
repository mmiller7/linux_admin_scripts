#!/bin/bash

# This pings a host about 300x a second and reports when
# it sees loss while logging to a file for reference.
# Useful to help manually track when loss is happening to
# troubleshoot issues with an ISP (not that having
# evidence helps convince them)

if [ "$1" == "" ];then
  host_ip='8.8.8.8'
else
  host_ip="$1"
fi
logfile="`dirname $0`/ping_loss_`echo "${host_ip}" | sed 's/\./-/g'`.log"

echo "Runtime config:"
echo "Host IP: $host_ip"
echo "Logfile: $logfile"

echo "Starting..." | tee -a "$logfile"
date | tee -a "$logfile"
echo "---------------------------------------------------------------------------" | tee -a "$logfile"

printNext=0

(
  while true; do
  ping -i 0.2 -c 300 -q "$host_ip"
  date
  sleep 0.1
  done
) | while read -r line; do

if [[ $printNext -gt 0 ]]; then
  printNext=$(($printNext-1))
  echo "$line" | tee -a "$logfile"

  if [[ $printNext -eq 0 ]]; then
    echo "---------------------------------------------------------------------------" | tee -a "$logfile"
  fi
else
  echo "$line" | egrep -q ' [1-9][0-9]*%' && printNext=2
  if [[ $printNext -eq 2 ]]; then
    echo "$line" | tee -a $logfile
  fi
fi
done
