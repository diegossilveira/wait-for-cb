`wait-for-cb.sh` is a bash script that will wait on the availability of a given couchbase bucket.  It is useful for synchronizing the spin-up of interdependent services, such as linked docker containers.

## Dependencies

`wait-for-cb.sh` relies on [jsawk](https://github.com/micha/jsawk) to parse JSON responses from couchbase. This `jsawk` script depends on `js` interpreter, which should be installed as well. See [jsawk](https://github.com/micha/jsawk) for more details.

## Usage

```
wait-fot-cb.sh [options] [-- COMMAND]
-h, --host HOST            Couchbase host or IP
-p, --port PORT            Couchbase TCP port
-b, --bucket BUCKET_NAME   Couchbase bucket name
-u, --user USER            Couchbase admin username
-P, --password PASSWORD    Couchbase admin password
-a, --jsawk JSAWK_PATH     jsawk binary path. Defaults to $PATH/jsawk
-j, --js JS_PATH           js engine binary path (e.g. spidermonkey). Defaults to $PATH/js
-t, --attempts ATTEMPTS    Attempts before failing. Defaults to 3
```
