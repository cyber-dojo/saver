
# API
- - - -
## POST assert(command)
Runs a single [command](#command).  
- result [(JSON-out)](#json-out)
  - When it succeeds, the single result of the `command`.
  - When it fails, raises `ServiceError`.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/katas/12/34/56
  $ curl \
    --data '{"command":["dir_make","${DIRNAME}"]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/assert

  {"assert":true}
  ```

- - - -
## POST run(command)
Runs a single [command](#command).  
- result [(JSON-out)](#json-out)
  - The single result of the `command`.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/katas/34/E3/R6
  $ curl \
    --data '{"command":["dir_make","${DIRNAME}"]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run

  {"run":true}
  ```

- - - -
## POST assert_all(commands)
Runs all [commands](#commands).  
- result [(JSON-out)](#json-out)
  - When they all succeed, the `commands` results in an array.  
  - When one of them fails, immediately raises `ServiceError`.  
- example
  ```bash
  $ DIRNAME=/cyber-dojo/groups/45/Pe/6N
  $ curl \
    --data '{"commands":[["dir_make","${DIRNAME}"],["dir_exists?","${DIRNAME}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/assert_all

  {"assert_all":[true,true]}
  ```

- - - -
## POST run_all(commands)
Runs all [commands](#commands).
- result [(JSON-out)](#json-out)  
  - The `commands` results, in an array.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/groups/2P/45/6E
  $ curl \
    --data '{"commands":[["dir_make","${DIRNAME}"],["dir_make","${DIRNAME}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run_all

  {"run_all":[true,false]}
  ```

- - - -
## POST run_until_true(commands)
Runs [commands](#commands) until one is **true**.  
- result [(JSON-out)](#json-out)
  - The `commands` results (including the last **true** one) in an array.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/groups/12/5Q/6E
  $ curl \
    --data '{"commands":[["dir_exists?","${DIRNAME}"],["dir_make","${DIRNAME}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run_until_true

  {"run_until_true":[false,true]}
  ```

- - - -
## POST run_until_false(commands)
Runs [commands](#commands) until one is **false**.
- result [(JSON-out)](#json-out)
  - The `commands` results (including the last **false** one) in an array.
- example
  ```bash
  $ DIRNAME=/cyber-dojo/groups/1q/K4/d9
  $ curl \
    --data '{"commands":[["dir_make","${DIRNAME}"],["dir_make","${DIRNAME}"]]}' \
    --header 'Content-type: application/json' \
    --silent \
    -X POST \
      http://${IP_ADDRESS}:${PORT}/run_until_false

  {"run_until_false":[true,false]}
  ```

- - - -
## commands
An array of commands.

## command
There are 5 commands:
* [dir_make_command](#dir_make_command)
* [dir_exists_command](#dir_exists_command)
* [file_create_command](#file_create_command)
* [file_append_command](#file_append_command)
* [file_read_command](#file_read_command)
They can all be used in the 6 methods `assert`, `run`, `assert_all`, `run_all`, `run_until_true`, `run_until_false`.   
The 6 methods _always_ raise when
  * there is no space left on the file-system.  
  * `command` or `commands` is malformed (eg unknown, incorrect arity, not a String)
The 2 methods `assert` or `assert_all` raise instead of returning **false**.

- - - -
### dir_make_command
A command to create a dir.  
An array of two elements `[ "dir_make", "${DIRNAME}" ]`  
Corresponds to the `bash` command `mkdir -p ${DIRNAME}`.
- example
  ```json
  [ "dir_make", "/cyber-dojo/katas/4R/5S/w4" ]
  ```
- result
  * **true** when the `dir_make` succeeds.
  * **false** when the `dir_make` fails.
    - when **DIRNAME** already exists as a dir.
    - when **DIRNAME** already exists as a file.

- - - -
### dir_exists_command
A query to determine if a dir exists.  
An array of two elements `[ "dir_exists?", "${DIRNAME}" ]`  
Corresponds to the `bash` command `[ -d ${DIRNAME} ]`.    
- example
  ```json
  [ "dir_exists?", "/cyber-dojo/katas/4R/5S/w4" ]
  ```
- result
  * **true** when **DIRNAME** exists.
  * **false** when **DIRNAME** does not exist.

- - - -
### file_create_command
A command to create a _new_ file.  
An array of three elements `[ "file_create", "${FILENAME}", "${CONTENT}" ]`  
Creates a _new_ file called **FILENAME** with content **CONTENT** in an _existing_ dir (created with a `dir_make_command`).
- example
  ```json
  [ "file_create", "/cyber-dojo/katas/4R/5S/w4/manifest.json", "{...}" ]
  ```
- result
  * **true** when the file creation succeeds.
  * **false** when the file creation fails.
    - when **FILENAME** already exists.
    - when **FILENAME** exists as a dir.

- - - -
### file_append_command
A command to append to an _existing_ file.  
An array of three elements `[ "file_create", "${FILENAME}","${CONTENT}" ]`  
Appends **CONTENT** to an _existing_ file called **FILENAME** (created with a `file_create_command`)
- example
  ```json
  [ "file_append", "/cyber-dojo/katas/4R/5S/w4/manifest.json", "{...}" ]  
  ```
- result
  * **true** when the file append succeeds.
  * **false** when the file append fails.
    - when **FILENAME** does not exist.
    - when **FILENAME** exists as a dir.

- - - -
### file_read_command
A command to read from an _existing_ file.  
An array of two elements `[ "file_read", "${FILENAME}" ]`  
Reads the contents of an _existing_ file called **FILENAME**.
- example
  ```json
  [ "file_read", "/cyber-dojo/katas/4R/5S/w4/manifest.json" ]
  ```
- result
  * the contents of the file when the read succeeds.
  * **false** when the file read fails.
    - when **FILENAME** does not exist.
    - when **FILENAME** exists as a dir.

- - - -
## GET alive?
Tests if the service is alive.  
Used as a [Kubernetes](https://kubernetes.io/) liveness probe.  
- parameters
  * none
- result [(JSON-out)](#json-out)
  * **true**
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/alive?

  {"alive?":true}
  ```

- - - -
## GET ready?
Tests if the service is ready to handle requests.  
Used as a [Kubernetes](https://kubernetes.io/) readiness probe.
- parameters
  * none
- result [(JSON-out)](#json-out)
  * **true** when the service is ready
  * **false** when the service is not ready
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/ready?

  {"ready?":false}
  ```

- - - -
## GET sha
The git commit sha used to create the Docker image.
- parameters
  * none
- result [(JSON-out)](#json-out)
  * the 40 character commit sha string.
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/sha

  {"sha":"41d7e6068ab75716e4c7b9262a3a44323b4d1448"}
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
