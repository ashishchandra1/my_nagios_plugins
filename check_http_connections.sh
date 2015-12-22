#!/usr/bin/env bash
# Author: Ashish Chandra <mail.ashishchandra@gmail.com>

# Exit Codes for nagios
OK=0
WARNING=1
CRITICAL=2
UNKNOWN=3

usage()
{
cat <<EOF
Check the number of HTTP connections/sockets in a given state.
Uses netstat tool to retrieve connections.
  Options:
    -s        State of connection (def: all)
    	      (ESTABLISHED, SYN_SENT, SYN_RECV, FIN_WAIT1, FIN_WAIT2, TIME_WAIT,
    	           CLOSED, CLOSE_WAIT, LAST_ACK, LISTEN, and CLOSING)
    -c        Critical threshold as an integer
    -w        Warning threshold as an integer
Usage: $0 -s ESTABLISHED -w 800 -c 1000
EOF
}

argcheck() {
# if less than n argument
if [ $ARGC -lt $1 ]; then
  echo "Missing arguments! Use \`\`-h'' for help."
  exit 1
fi
}

if ! command -v ss >/dev/null 2>&1; then
  echo -e "ERROR: netstat is not installed or not found in \$PATH!"
  exit 1
fi

# Define now to prevent expected number errors
STATE=all
CRIT=0
WARN=0
COUNT=0
ARGC=$#
CHECK=0

argcheck 1

while getopts "hc:s:w:" OPTION
do
  case $OPTION in
    h)
      usage
      ;;
    s)
      STATE="$OPTARG"
      CHECK=1
      ;;
    c)
      CRIT="$OPTARG"
      CHECK=1
      ;;
    w)
      WARN="$OPTARG"
      CHECK=1
      ;;
    \?)
      exit 1
      ;;
  esac
done

#COUNT=$(ss -n state $STATE $PROTOCOL $FILTER | grep -v 'State\|-Q' | wc -l)
COUNT=$(netstat -pan | grep -w 80 | grep $STATE| wc -l)

if [ $COUNT -gt $CRIT ]; then
  echo "$COUNT sockets in $STATE state!"
  exit $CRITICAL
elif [ $COUNT -gt $WARN ]; then
  echo "$COUNT sockets in $STATE state!"
  exit $WARNING
else
  echo "$COUNT sockets in $STATE state."
  exit $OK
fi
