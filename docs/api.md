
# API
- - - -
## POST assert(command)
Runs [command](#command) raising `ServiceError` if it fails.
- example
  ```bash
  $ curl \
    --data '{"command":["dir_make","/cyber-dojo/katas/12/34/56"]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/assert

  {"assert":true}
  ```

- - - -
## POST run(command)
Runs [command](#command).
- example
  ```bash
  $ dirname=/cyber-dojo/katas/34/E3/R6
  $ curl \
    --data '{"command":["dir_make","${dirname}"]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run

  {"run":false}
  ```

- - - -
## POST assert_all(commands)
Runs all [commands](#commands) raising `ServiceError` if any of them fail.
- example
  ```bash
  $ dirname=/cyber-dojo/groups/12/45/6E
  $ curl \
    --data '{"commands":[["dir_make","${dirname}"],["dir_exists?","${dirname}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/assert_all

  {"assert_all":[true,true]}
  ```

- - - -
## POST run_all(commands)
Runs all [commands](#commands) returning their results in an array.
- example
  ```bash
  $ dirname=/cyber-dojo/groups/12/45/6E
  $ curl \
    --data '{"commands":[["dir_make","${dirname}"],["dir_make","${dirname}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run_all

  {"run_all":[true,false]}
  ```

- - - -
## POST run_until_true(commands)
Runs commands [commands](#commands) until one is not true, returning the results
(including the non true one) in an array.
- example
  ```bash
  $ dirname=/cyber-dojo/groups/12/45/6E
  $ curl \
    --data '{"commands":[["dir_make","${dirname}"],["dir_make","${dirname}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run_until_true

  {"run_until_true":[true]}
  ```

- - - -
## POST run_until_false(commands)
Runs commands [commands](#commands) until one is not false, returning the results
(including the false one) in an array.
- example
  ```bash
  $ dirname=/cyber-dojo/groups/12/45/6E
  $ curl \
    --data '{"commands":[["dir_make","${dirname}"],["dir_make","${dirname}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run_until_false

  {"run_until_true":[true,false]}
  ```


- - - -
## GET ready?
Tests if the service is ready to handle requests.
Used as a [Kubernetes](https://kubernetes.io/) readiness probe.
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * **true** if the service is ready
  * **false** if the service is not ready
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/ready?

  {"ready?":false}
  ```

- - - -
## GET alive?
Tests if the service is alive.
Used as a [Kubernetes](https://kubernetes.io/) liveness probe.  
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * **true**
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/alive?

  {"alive?":true}
  ```

- - - -
## GET sha
The git commit sha used to create the Docker image.
- parameters
  * none
- returns [(JSON-out)](#json-out)
  * the 40 character commit sha string.
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/sha

  {"sha":"41d7e6068ab75716e4c7b9262a3a44323b4d1448"}
  ```

- - - -
## commands
An array of [command]s(#commands)s


## command
There are 5 core commands
* dir_make
* dir_exists?
* file_create
* file_append
# file_read

- - - -
# dir_make(key)
Creates **key** to allow subsequent calls to ```write``` and ```append```.
Corresponds to ```mkdir -p ${key}``` on a file-system.
- parameter
  * **key** a dir-like **String**, eg
  ```json
  { "key": "katas/N2/u8/9W" }
- returns
  * **true** if there has _not_ been a previous call to ```create``` with the given **key**
  ```json
  { "create": true }
  ```
  * **false** if the ```create``` fails, eg there _has_ been a previous call to ```create``` with the given **key**
  ```json
  { "create": false }
  ```

- - - -
# dir_exists?(key)
Determines if there has been a previous call to ```create``` with the given **key**.
Corresponds to the bash command ```[ -d ${key} ]``` on a file-system.
- parameter
  * **key** a dir-like **String**, eg
  ```json
  { "key": "katas/N2/u8/9W" }
  ```
- returns
  * **true** if there _has_ been a previous call to ```create``` with the given **key**
  ```json
  { "exists?": true }
  ```
  * **false** if there has _not_ been a previous call to ```create``` with the given **key**
  ```json
  { "exists?": false }
  ```

- - - -
# file_create(key,value)
Saves **value** against a new **key**.
Corresponds to saving **value** in a _new_ file called **key** in an _existing_ dir on a file-system.
- parameters
  * **key** a full-filename-like **String**
  * **value** a **String**
  ```json
  { "key": "katas/N2/u8/9W/manifest.json",
    "value": "{\"image_name\":...}"
  }
  ```
- returns
  * **true** if the ```write``` succeeds.
  ```json
  { "write": true }
  ```
  * **false** if the ```write``` fails, eg because **key** already exists, or a call
  to ```create()``` with the base-dir of **key** has _not_ previously occurred.
  ```json
  { "write": false }
  ```

- - - -
# file_append(key,value)
Appends **value** to the existing **key**.
Corresponds to appending **value** to an _existing_ file called **key** on a file-system.
- parameters
  * **key** a full-filename-like **String**
  * **value** a **String**
  ```json
  { "key": "katas/N2/u8/9W/events.json",
    "value": "{...}"
  }
  ```
- returns
  * **true** if the ```append``` succeeds
  ```json
  { "append": true }
  ```
  * **false** if the ```append``` fails, eg because a successful call to ```write(key,...)```
  has _not_ previously occurred.
  ```json
  { "append": false }
  ```

- - - -
# file_read(key)
Reads the value saved against **key**.
Corresponds to reading the contents of an _existing_ file called **key** on a file-system.
- parameter
  * **key** a full-filename-like **String**
  ```json
  { "key": "katas/N2/u8/9W/events.json" }
  ```
- returns
  * **String** stored against **key** if the ```read``` succeeds.
  ```json
  { "read": "{...}" }
  ```
  * **false** if the ```read``` fails, eg because there was no previous successful call
  to ```write``` with the given **key**.
  ```json
  { "read": false }
  ```

- - - -
## JSON in
- All methods pass any arguments as a json hash in the http request body.
  * If there are no arguments you can use `''` (which is the default
    for `curl --data`) instead of `'{}'`.

- - - -
## JSON out      
- All methods return a json hash in the http response body.
  * If the method completes, a string key equals the method's name. eg
    ```bash
    $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/ready?

    {"ready?":true}
    ```
  * If the method raises an exception, a string key equals `"exception"`, with
    a json-hash as its value. eg
    ```bash
    $ curl --silent -X POST http://${IP_ADDRESS}:${PORT}/assert_all | jq      

    {
      "exception": {
        "path": "/assert_all",
        "body": "",
        "class": "SaverService",
        "message": "...",
        "backtrace": [
          ...
          "/usr/bin/rackup:23:in `<main>'"
        ]
      }
    }
    ```
