#!/bin/bash

wait_for_couchbase()
{
   for (( i=1; i<=$ATTEMPTS; i++ ))
   do
      print_progress $i
      result=$(check_bucket_status)
      if [[ $result == "healthy" ]]
      then
         echo -e "\nBucket ${BUCKET} is healthy"
         run_command
         break
      fi
      sleep 1
   done
   echo -e "\nMax attempts reached."
}

print_progress()
{
   percentage=$((($1*100)/$ATTEMPTS))
   echo -n " ["
   for (( p=0; p<$percentage; p++)) do echo -n "#"; done
   for (( ; p<100; p++)) do echo -n " "; done
   p=0
   echo -ne "] $1/$ATTEMPTS\r"
}

check_bucket_status()
{
   url="http://${HOST}:${PORT}/pools/default/buckets/${BUCKET}"
   credentials="${USER}:${PASSWORD}"
   result=`curl -s -u $credentials $url | $JS_AWK 'return this.nodes[0].status' 2> /dev/null`
   echo $result
}

run_command()
{
   if [[ $COMMAND != "" ]]
   then
      eval $COMMAND
   fi
}

usage()
{
   cat << USAGE >&2
Usage:
   $(basename $0) [options] [-- COMMAND]
   -h, --host HOST            Couchbase host or IP
   -p, --port PORT            Couchbase TCP port
   -b, --bucket BUCKET_NAME   Couchbase bucket name
   -u, --user USER            Couchbase admin username
   -P, --password PASSWORD    Couchbase admin password
   -a, --jsawk JSAWK_PATH     jsawk binary path. Defaults to $PATH/jsawk
   -j, --js JS_PATH           js engine binary path (e.g. spidermonkey). Defaults to $PATH/js
   -t, --attempts ATTEMPTS    Attempts before failing. Defaults to 3
USAGE
   exit 1
}

parse_arguments()
{
   while [[ $# -gt 0 ]]
   do
      case "$1" in
         -h | --host)
         HOST="$2"
         shift 2
         ;;
         -p | --port)
         PORT="$2"
         shift 2
         ;;
         -a | --jsawk)
         JS_AWK="$2"
         shift 2
         ;;
         -j | --js)
         JS="$2"
         shift 2
         ;;
         -b | --bucket)
         BUCKET="$2"
         shift 2
         ;;
         -u | --user)
       	 USER="$2"
         shift 2
         ;;
         -P | --password)
         PASSWORD="$2"
         shift 2
         ;;
         -t | --attempts)
         ATTEMPTS="$2"
         shift 2
         ;;
         --)
         shift
         COMMAND="$@"
         break
         ;;
         --help)
         usage
         ;;
         *)
         usage
         ;;
      esac
   done
}

initialize_arguments()
{
   if [[ "$HOST" == "" ]]
   then
      echoerr "Error: you need to provide a couchbase host."
      usage
   fi

   if [[ "$BUCKET" == "" ]]
   then
      echoerr "Error: you need to provide a couchbase bucket name."
      usage
   fi

   if [[ "$USER" == "" ]]
   then
      echoerr "Error: you need to provide a couchbase user."
      usage
   fi

   if [[ "$PASSWORD" == "" ]]
   then
      echoerr "Error: you need to provide a couchbase password."
      usage
   fi

   if [[ "$PORT" == "" ]]
   then
      PORT="8091"
   fi

   if [[ "$JS_AWK" == "" ]]
   then
      JS_AWK="jsawk"
   fi

   if [[ "$JS" == "" ]]
   then
     JS="js"
   fi

   if [[ "$ATTEMPTS" == "" ]]
   then
     ATTEMPTS=3
   fi
}

echoerr()
{
   echo "$@" 1>&2
}

parse_arguments $@

initialize_arguments

wait_for_couchbase
