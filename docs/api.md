# API 
- [(JSON-in)](#json-in) All methods pass their argument in a json hash in the http request body.
- [(JSON-out)](#json-out) All methods return a json hash in the http response body.

- - - -
## POST group_create(manifests:,options:)
Creates a new group exercise from `manifests[0]`, and returns its id.
- parameters 
  * **manifests:[Hash,...]**.
  For example, a [custom-start-points](https://github.com/cyber-dojo/custom-start-points) manifest.  
  * **options:Hash**.
  Currently unused (and defaulted). For a planned feature.
- returns 
  * the `id` of the created group.
- notes
  * At present only `manifests[0]` is used and `options` is used.
    The array will allow a group to have more than one exercise.
    The options will allow settings such as theme (light|dark) and colour-syntax (on|off) to be defaulted at creation.

- - - -
## GET group_exists?(id:)
Determines if a group exercise with the given `id` exists.
- parameters 
  * **id:String**.
- returns 
  * `true` if a group with the given `id` exists, otherwise `false`.
- example
  ```bash
  $ curl \
    --data '{"id:"dFg8Us"}' \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      http://${IP_ADDRESS}:${PORT}/group_exists?

  {"group_exists?":true}
  ```

- - - -
## GET group_manifest(id:)
Gets the manifest used to create the group exercise with the given `id`.
- parameters
  * **id:String**.
- returns
  * the manifest of the group with the given `id`.
- example
  ```bash
  $ curl \
    --data '{"id:"dFg8Us"}' \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      http://${IP_ADDRESS}:${PORT}/group_manifest | jq

  {
    "group_manifest": {
      "display_name": "Bash, bats",
      "image_name": "cyberdojofoundation/bash_bats:53d0c9c",
      "filename_extension": [
        ".sh"
      ],
      "tab_size": 4,
      "visible_files": {
        "test_hiker.sh": { "content": "..." },
        "bats_help.txt": { "content": "..." },
        "hiker.sh": { "content": "..." },
        "cyber-dojo.sh": { "content": "..." },
        "readme.txt": { "content": "..." }
      },
      "exercise": "LCD Digits",
      "version": 1,
      "created": [2020,10,19,12,51,32,991192],
      "id": "REf1t8",
      "highlight_filenames": [],
      "max_seconds": 10,
      "progress_regexs": []
    }
  }  
  ```

- - - -
## POST group_join(id:,indexes:)
Creates a new kata in the group with the given `id` and returns the kata's id.
- parameters 
  * **id:String**.
  * **indexes:Array[int]**
  Currently unused (and defaulted). For a planned feature.  
- returns 
  * the `id` of the created kata, or `null` if the group is already full.
- example
  ```bash
  $ curl \
    --data '{"id:"dFg8Us"}' \
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      http://${IP_ADDRESS}:${PORT}/group_join

  {"group_join":"a8gVRN"}
  ```

- - - -
## GET group_joined(id:)
Returns the kata-id and kata-events keyed against the kata's avatar-index (0-63)
for the katas that have joined a group. The group can be specified with the group's `id`
**or** with the `id` of any kata in the group.
- parameters 
  * **id:String**.
- returns 
  * a **Hash**.
- example
  ```bash
  $ curl \
    --data '{"id:"dFg8Us"}' \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      http://${IP_ADDRESS}:${PORT}/group_joined | jq

  {
    "group_joined": {
      "7": {
        "id": "a8gVRN",
        "events": [...]
      },
      "29": {
        "id": "gUNjUV",
        "events": [...]
      },
      ...
     }
  }
  ```

- - - -
## POST kata_create(manifest:,options:)
Creates a new kata exercise from `manifest`, and returns its id.
- parameters 
  * **manifest:Hash**.
  For example, a [custom-start-points](https://github.com/cyber-dojo/custom-start-points) manifest.  
  * **options:Hash**.
  Currently unused (and defaulted). For a planned feature.
- returns 
  * the `id` of the created kata.

- - - -
## GET kata_exists?(id:)
Determines if a kata exercise with the given `id` exists.
- parameters 
  * **id:String**.
- returns 
  * `true` if a kata with the given `id` exists, otherwise `false`.
- example
  ```bash
  $ curl \
    --data '{"id:"4ScKVJ"}' \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      http://${IP_ADDRESS}:${PORT}/kata_exists?

  {"kata_exists?":false}
  ```

- - - -
## GET kata_manifest(id:)
Gets the manifest used to create the kata exercise with the given `id`.
- parameters 
  * **id:String**.
- returns 
  * the manifest of the kata with the given `id`.
- example
  ```bash
  $ curl \
    --data '{"id:"4ScKVJ"}' \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      http://${IP_ADDRESS}:${PORT}/kata_manifest | jq

  {
    "kata_manifest": {
      "display_name": "Bash, bats",
      "image_name": "cyberdojofoundation/bash_bats:53d0c9c",
      "filename_extension": [ ".sh" ],
      "tab_size": 4,
      "visible_files": {
        "test_hiker.sh": { "content": "..." },
        "bats_help.txt": { "content": "..." },
        "hiker.sh": { "content": "..." },
        "cyber-dojo.sh": { "content": "..." },
        "readme.txt": { "content": "..." }
      },
      "exercise": "LCD Digits",
      "version": 1,
      "created": [2020,10,19,12,52,46,396907],
      "group_id": "REf1t8",
      "group_index": 44,
      "id": "4ScKVJ",
      "highlight_filenames": [],
      "max_seconds": 10,
      "progress_regexs": []
    }
  }  
  ```


- - - -
## GET kata_events(id:)
Gets the summary of all current events for the kata with the given `id`.
- parameters 
  * **id:String**.
- returns 
  * an Array holding the events summary of the kata with the given `id`.
- example
  ```bash
  $ curl \
    --data '{"id:"4ScKVJ"}' \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      http://${IP_ADDRESS}:${PORT}/kata_events | jq

  {
    "kata_events": [
      { "index": 0,
         "time": [2020,10,19,12,52,46,396907],
         "event": "created"
      },
      { "time": [2020,10,19,12,52,54,772809],
        "duration": 0.491393,
        "colour": "red",
        "predicted": "none",
        "index": 1
      },
      { "time": [2020,10,19,12,52,58,547002],
        "duration": 0.426736,
        "colour": "amber",
        "predicted": "none",
        "index": 2
      },
      { "time": [2020,10,19,12,53,3,256202],
        "duration": 0.438522,
        "colour": "green",
        "predicted": "none",
        "index": 3
      }
    ]
  }
  ```


- - - -
## GET kata_event(id:,index:)
Gets the full details for the kata event whose kata has the given `id` whose event has the given `index`.
- parameters 
  * **id:String**.
  * **index:int**.
- returns 
  * the event with the given `id` and `index`.
- example
  ```bash
  $ curl \
    --data '{"id:"4ScKVJ","index":2}' \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      http://${IP_ADDRESS}:${PORT}/kata_event | jq

  {
     "kata_event": {
       "files": {
         "test_hiker.sh": { "content": "..." },
         "bats_help.txt": { "content": "..." },
         "hiker.sh": { "content": "..." },
         "cyber-dojo.sh": { "content": "..." },
         "readme.txt": { "content": "..." }
       },
       "stdout": {
         "content": "...",
         "truncated": false
       },
       "stderr": {
         "content": "...",
         "truncated": false
       },
       "status": "1",
       "time": [2020,10,19,12,52,58,547002],
       "duration": 0.426736,
       "colour": "amber",
       "predicted": "none",
       "index": 2
     }
   }
   ```

- - - -
## GET katas_events(ids:,indexes:)
Gets the full details for the kata events with the given `ids` and `indexes`.
A Batch-Method for kata_event(id,index).
- parameters 
  * **ids:Array[String]**.
  * **index:Array[int]**.
- returns 
  * the events with the given `ids` and `indexes`.
- example
  ```bash
  $ curl \
    --data '{"ids:["4ScKVJ","De87Aa"],"indexes":[23,45]}' \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      http://${IP_ADDRESS}:${PORT}/katas_events | jq

  {
     "katas_events": {
       "4ScKVJ": {
         "23": {
           "files": { ... },
           "stdout": { ... }  
           ...
         }
       },
       "De87Aa": {
         "45": {
           "files": { ... },
           "stdout": { ... }  
           ...
         }
       }
     }
   }
   ```


- - - -
## POST kata_ran_tests(id:,index:,files:,stdout:,stderr:,status:,summary:)

- - - -
## POST kata_predicted_right(id:,index:,files:,stdout:,stderr:,status:,summary:)

- - - -
## POST kata_predicted_wrong(id:,index:,files:,stdout:,stderr:,status:,summary:)

- - - -
## POST kata_reverted(id:,index:,files:,stdout:,stderr:,status:,summary:)

- - - -
## POST kata_checked_out(id:,index:,files:,stdout:,stderr:,status:,summary:)

- - - -
## GET kata_option_get(id:,name:)

- - - -
## POST kata_option_set(id:,name:,value:)


- - - -
## GET alive?
Tests if the service is alive.  
Used as a [Kubernetes](https://kubernetes.io/) liveness probe.  
- parameters
  * none
- result 
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
- result 
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
- result 
  * the 40 character commit sha string.
- example
  ```bash     
  $ curl --silent -X GET http://${IP_ADDRESS}:${PORT}/sha

  {"sha":"41d7e6068ab75716e4c7b9262a3a44323b4d1448"}
  ```

- - - -
## POST assert(command)
Runs a single [command](#command).  
- result 
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
- result 
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
- result 
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
- result 
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
- result 
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
- result 
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
The 2 methods `assert` and `assert_all` raise instead of returning **false**.  
The 6 methods _always_ raise when
  * there is no space left on the file-system.  
  * `command` or `commands` is malformed (eg unknown, incorrect arity, not a String)

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
## JSON in
- All methods pass their argument in a json hash in the http request body.
  * For `alive?`,`ready?` and `sha` you can use `''` (which is the default for `curl --data`) instead of `'{}'`.
  * For `assert` and `run` the key must be `"command"`.
  * For `assert_all`, `run_all`, `run_until_true`, `run_until_false` the key must be `"commands"`.

- - - -
## JSON out      
- All methods return a json hash in the http response body.
  * If the method does not raise, a string key equals the method's name. eg
    ```bash
    $ curl --silent -X GET http://${HOST}:${PORT}/ready?

    {"ready?":true}
    ```
  * If the method raises an exception, a string key equals `"exception"`, with
    a json-hash as its value. eg
    ```bash
    $ curl --data 'not-json-hash' --silent -X GET http://${HOST}:${PORT}/run | jq      

    {
      "exception": {
        "path": "/run",
        "body": "not-json-hash",
        "class": "SaverService",
        "message": "...",
        "backtrace": [
          ...
          "/usr/bin/rackup:23:in `<main>'"
        ]
      }
    }
    ```
