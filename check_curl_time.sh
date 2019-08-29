#!/bin/bash
## Created By ##
## Efkan Isazade ##

# Mutable Nagios Exit Codes
OK=0
WARNING=1
CRITICAL=2

while getopts "w:c:" opt; do
        case $opt in
                w) warn_var="$OPTARG"  ;;
                c) crit_var="$OPTARG"  ;;
        esac
done

set -o errexit

main () {
  local url=$1
  if [[ -z "$url" ]]; then
    echo "ERROR:
  An URL must be provided.

  Usage: check_timeout <url> -w -c

Aborting.
    "
    exit 1
  fi

  print_header
   for i in `seq 1 1`; do
    make_request $url
  done
}

print_header () {
  echo "time_total"
}

make_request () {
  local url=$1
  curl \
    --header "your curl header" \
      $url \
    --silent \
    --output /dev/null \
    --write-out "%{time_total}\n"   #you can also use  %{http_code},%{time_connect},%{time_appconnect},%{time_starttransfer}
}

# here we need to convert floating result to an integer.
getval=$( printf "%.0f" $make_request )

main "$@"

if [ "$getval" -ge "$warn_var" ] ; then
        echo "Status is WARNING" && exit "$WARNING"
elif [ "$getval" -ge "$crit_var" ] ; then
        echo "Status is CRITICAL" && exit "$CRITICAL"
elif [ "$getval" -lt "$warn_var" ] ; then
        echo "Status is OK" && exit "$OK"
fi
