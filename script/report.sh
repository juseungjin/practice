#!/bin/bash

log_file="testall.sh.log"

function usage()
{
  echo "Usage: `basename $0` [-h] <log_file>"
  echo "  <log_file>        log file to report"
  echo "  -h                help"
  exit 1
}

if [ -z "$1" ]; then
  usage
fi

while getopts ":h" opt; do
  case $opt in
    h)
      usage
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      usage
      ;;
    :)
      echo "Option -$OPTARG requires an argument"
      usage
      ;;
  esac
done

if [ -n "$1" ]; then
  log_file="$1"
fi

function print_title()
{
  title="[$1]"
  title_len=${#title}
  echo
  echo -n "$title"
  for((i=0; i<$((80-title_len)); i++)); do
    echo -n "-"
  done
  echo
  echo
}

echo "Report from $log_file"

print_title "pageload"
cat $log_file | grep -i "PageLoad Results"

print_title "rotation"
cat $log_file | grep "Rotation completion time :\|total rotation time"

print_title "mem"
cat $log_file | grep "Max memory usage"

print_title "applaunch"
cat $log_file | grep -i "total time"

print_title "scroll"
cat $log_file | grep -i "fps avg\|drag stdev"

print_title "bench"
cat $log_file | grep "Benchmark Results"
