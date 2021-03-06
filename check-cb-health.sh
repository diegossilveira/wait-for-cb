#!/bin/bash

check()
{
  if [[ -z "$DESIGN_DOC" ]]
  then
     check_bucket_status
  else
     check_design_doc_status
  fi
}

check_bucket_status()
{
   url="http://${HOST}:${PORT}/pools/default/buckets/${BUCKET}"
   credentials="${USER}:${PASSWORD}"
   result=`curl -s -u $credentials $url | $JS_AWK -j $JS 'return this.nodes[0].status' 2> /dev/null`
   [ "$result" = "healthy" ]
}

check_design_doc_status()
{
   url="http://${HOST}:${PORT}/${BUCKET}/_design/${DESIGN_DOC}"
   credentials="${USER}:${PASSWORD}"
   curl -s -f -u $credentials $url > /dev/null
}

usage()
{
   cat << USAGE >&2
Usage:
   $(basename $0) [options] [-- COMMAND]
   -h, --host HOST                    Couchbase host or IP
   -p, --port PORT                    Couchbase TCP port
   -b, --bucket BUCKET_NAME           Couchbase bucket name
   -d, --design-doc DESIGN_DOC_NAME   Design Document name
   -u, --user USER                    Couchbase admin username
   -P, --password PASSWORD            Couchbase admin password
   -a, --jsawk JSAWK_PATH             jsawk binary path. Defaults to $PATH/jsawk
   -j, --js JS_PATH                   js engine binary path (e.g. spidermonkey). Defaults to $PATH/js
USAGE
   exit 3
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
         -d | --design-doc)
         DESIGN_DOC="$2"
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
   if [[ -z "$HOST" ]]
   then
      echoerr "Error: you need to provide a couchbase host."
      usage
   fi

   if [[ -z "$BUCKET" ]]
   then
      echoerr "Error: you need to provide a couchbase bucket name."
      usage
   fi

   if [[ -z "$USER" ]]
   then
      echoerr "Error: you need to provide a couchbase user."
      usage
   fi

   if [[ -z "$PASSWORD" ]]
   then
      echoerr "Error: you need to provide a couchbase password."
      usage
   fi

   if [[ -z "$PORT" ]]
   then
      PORT="8091"
   fi

   if [[ -z "$JS_AWK" ]]
   then
      JS_AWK="jsawk"
   fi

   if [[ -z "$JS" ]]
   then
     JS="js"
   fi

   if [[ -z "$ATTEMPTS" ]]
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

check