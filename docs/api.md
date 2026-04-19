# API 

- [(JSON-in)](#json-in) All methods pass their argument in a json hash in the HTTP request body.
- [(JSON-out)](#json-out) All methods return a json hash in the HTTP response body.
- GET is used for queries.
- POST is used for modifiers.
- Paths are *not* REST-ful.


- - - -
# Group API

## POST group_create(manifest)
Creates a new group from the given `manifest` and returns its id.  
See `group_manifest` below for a `manifest` overview.  
See [here](https://blog.cyber-dojo.org/2016/08/cyber-dojo-start-points-manifestjson.html) for more detailed `manifest` information.
- parameters 
  * **manifest:Hash** created by 
  [creator](https://github.com/cyber-dojo/creator) 
  from
  [languages-start-points](https://github.com/cyber-dojo/languages-start-points) and
  [exercises-start-points](https://github.com/cyber-dojo/exercises-start-points) or
  [custom-start-points](https://github.com/cyber-dojo/custom-start-points).
- returns 
  * the `id` of the created group.
- example
  ```bash
  $ curl \
    --data '{"manifest":...}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/group_create | jq .
  ```
  ```bash
  {
    "group_create":  "dFg8Us"
  }
  ```


- - - -
## GET group_manifest(id)
Gets the manifest used to create the group with the given `id`.
- parameters
  * **id:String**. The group id.
- returns
  * the manifest of the group with the given `id`.
- example
  ```bash
  $ curl \
    --data '{"id":"dFg8Us"}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/group_manifest | jq .
  ```
  ```bash
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
## GET group_exists?(id)
Determines if a group with the given `id` exists.
- parameters 
  * **id:String**. The group id.
- returns 
  * `true` if a group with the given `id` exists, otherwise `false`.
- example
  ```bash
  $ curl \
    --data '{"id":"dFg8Us"}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/group_exists? | jq .
  ```
  ```bash
  {
    "group_exists?": true
  }
  ```

- - - -
## POST group_join(id)
Creates a new kata in the group with the given `id` and returns the kata's id.
- parameters 
  * **id:String**. The group id.
- returns 
  * the `id` of the created kata, or `null` if the group is already full.
- example
  ```bash
  $ curl \
    --data '{"id":"dFg8Us"}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/group_join | jq .
  ```
  ```bash
  {
    "group_join": "a8gVRN"
  }
  ```


- - - -
## GET group_joined(id)
Returns the kata-id and kata-events-summary keyed against the kata's avatar-index (0-63)
for the katas that have joined a group. 
- parameters 
  * **id:String**. The group's `id` **or** the `id` of any kata in the group.
- returns 
  * a **Hash**.
- example
  ```bash
  $ curl \
    --data '{"id":"dFg8Us"}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/group_joined | jq .
  ```
  ```bash
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
## POST group_fork(id,index)
Creates a new group whose starting files are a copy of the files in the kata with 
the given `id` at the given `index`. The new group is *not* a fork in the git sense;
that is, it is *not* a 'deep' copy, the history of commits (one per test event)
that exist in the kata being forked are *not* copied.
- parameters 
  * **id:String**. The id of the kata being forked.
  * **index:int**. The event index to fork from.
- returns 
  * the `id` of the created group.
- example
  ```bash
  $ curl \
    --data '{"id":"dFg8Us", "index":23}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/group_fork | jq .
  ```
  ```bash
  {
    "group_fork": "a8gVRN"
  }
  ```


- - - -
# Kata API

## POST kata_create(manifest)
Creates a new kata from the given `manifest` and returns its id.  
See `kata_manifest` below for a `manifest` overview.  
See [here](https://blog.cyber-dojo.org/2016/08/cyber-dojo-start-points-manifestjson.html) for more detailed `manifest` information.
- parameters 
  * **manifest:Hash** created by 
  [creator](https://github.com/cyber-dojo/creator) 
  from
  [languages-start-points](https://github.com/cyber-dojo/languages-start-points) and
  [exercises-start-points](https://github.com/cyber-dojo/exercises-start-points) (or
  [custom-start-points](https://github.com/cyber-dojo/custom-start-points)).
- returns 
  * the `id` of the created kata.
- example
  ```bash
  $ curl \
    --data '{"manifest":...}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/kata_create | jq .
  ```
  ```bash
  {
    "kata_create":  "dFg8Us"
  }
  ```


- - - -
## GET kata_manifest(id)
Gets the manifest used to create the kata exercise with the given `id`.
- parameters 
  * **id:String**. The kata id.
- returns 
  * the manifest of the kata with the given `id`.
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ"}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/kata_manifest | jq .
  ```
  ```bash
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
## GET kata_exists?(id)
Determines if a kata exercise with the given `id` exists.
- parameters 
  * **id:String**. The kata id.
- returns 
  * `true` if a kata with the given `id` exists, otherwise `false`.
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ"}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/kata_exists? | jq .
  ```
  ```bash
  {
    "kata_exists?": false
  }
  ```


- - - -
## GET kata_events(id)
Gets the summary of all current events for the kata with the given `id`.
- parameters 
  * **id:String**. The kata id.
- returns 
  * an Array holding the events summary of the kata with the given `id`.
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ"}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/kata_events | jq .
  ```
  ```bash
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
## GET kata_event(id,index)
Gets the full details for the kata event whose kata has the given `id` whose event has the given `index`.
- parameters 
  * **id:String**. The kata id.
  * **index:int**. Negative values count backwards, -1 is the last index.
- returns 
  * the event with the given `id` and `index`.
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","index":2}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/kata_event | jq .
  ```
  ```bash
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
## GET katas_events(ids,indexes)
Gets the full details for the kata events with the given `ids` and `indexes`.
A Batch-Method for kata_event(id,index).
- parameters 
  * **ids:Array[String]**. The kata ids.
  * **index:Array[int]**. The corresponding event indexes.
- returns 
  * the events with the given `ids` and `indexes`.
- example
  ```bash
  $ curl \
    --data '{"ids":["4ScKVJ","De87Aa"],"indexes":[23,45]}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/katas_events | jq .
  ```
  ```bash
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
## GET kata_download(id)
Returns a gzipped tar archive of the kata's git repository, base64-encoded.
- parameters
  * **id:String**. The kata id.
- returns
  * an Array of two elements: the suggested filename (`String`) and the base64-encoded tgz content (`String`).
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ"}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/kata_download | jq .
  ```
  ```bash
  {
    "kata_download": [
      "cyber-dojo-2026-4-6-4ScKVJ.tgz",
      "H4sIAAAAAAAAA+..."
    ]
  }
  ```


- - - -
## POST kata_file_create(id,index,files,filename)
Records a new empty file being created in the browser. If any existing file has been edited since the last save, that edit is recorded first as a `file_edit` event.
- parameters
  * **id:String**. The kata id.
  * **index:int**. The next event index.
  * **files:Hash**. The current files (the new `filename` is not yet present).
  * **filename:String**. The name of the file being created.
- returns
  * the event index to use for the next call.
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","index":4,"files":{...},"filename":"utils.sh"}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/kata_file_create | jq .
  ```
  ```bash
  {
    "kata_file_create": 5
  }
  ```


- - - -
## POST kata_file_delete(id,index,files,filename)
Records a file being deleted in the browser. If any existing file has been edited since the last save, that edit is recorded first as a `file_edit` event.
- parameters
  * **id:String**. The kata id.
  * **index:int**. The next event index.
  * **files:Hash**. The current files (the `filename` to delete is still present).
  * **filename:String**. The name of the file being deleted.
- returns
  * the event index to use for the next call.
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","index":5,"files":{...},"filename":"utils.sh"}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/kata_file_delete | jq .
  ```
  ```bash
  {
    "kata_file_delete": 6
  }
  ```


- - - -
## POST kata_file_rename(id,index,files,old_filename,new_filename)
Records a file being renamed in the browser. If any existing file has been edited since the last save, that edit is recorded first as a `file_edit` event.
- parameters
  * **id:String**. The kata id.
  * **index:int**. The next event index.
  * **files:Hash**. The current files (`old_filename` is present; `new_filename` is not yet present).
  * **old_filename:String**. The current name of the file.
  * **new_filename:String**. The new name of the file.
- returns
  * the event index to use for the next call.
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","index":6,"files":{...},"old_filename":"utils.sh","new_filename":"helpers.sh"}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/kata_file_rename | jq .
  ```
  ```bash
  {
    "kata_file_rename": 7
  }
  ```


- - - -
## POST kata_file_edit(id,index,files)
Records a file edit event if any file content has changed since the last save. If no file has changed, no event is recorded and the same `index` is returned.
- parameters
  * **id:String**. The kata id.
  * **index:int**. The next event index.
  * **files:Hash**. The current files.
- returns
  * the (possibly unchanged) event index to use for the next call.
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","index":7,"files":{...}}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/kata_file_edit | jq .
  ```
  ```bash
  {
    "kata_file_edit": 7
  }
  ```


- - - -
## POST kata_ran_tests(id,index,files,stdout,stderr,status,summary)
Record a test event with no prediction.
- parameters 
  * **id:String**. The kata id.
  * **index:int**. The next event index.
  * **files:Hash**. The files which created `stdout`,`stderr`,`status` in the same format as [kata_event](#get-kata_eventidindex)
  * **stdout:Hash**. The stdout produced from `files`, in the same format as [kata_event](#get-kata_eventidindex)
  * **stderr:Hash**. The stderr produced from `files`, in the same format as [kata_event](#get-kata_eventidindex)
  * **status:String**. The status produced from `files`, in the same format as [kata_event](#get-kata_eventidindex)
  * **summary:Hash**. Extra event data to store, eg `duration`,`time`,`colour`


- - - -
## POST kata_predicted_right(id,index,files,stdout,stderr,status,summary)
Record a test event with a correct prediction.


- - - -
## POST kata_predicted_wrong(id,index,files,stdout,stderr,status,summary)
Record a test event with an incorrect prediction.


- - - -
## POST kata_reverted(id,index,files,stdout,stderr,status,summary)
Revert back to a previous traffic-light.


- - - -
## POST kata_checked_out(id,index,files,stdout,stderr,status,summary)
Checkout a traffic-light from a different avatar.


- - - -
## GET kata_option_get(id,name)
Get a theme (dark/light) or colour (on/off) or prediction (on/off) option.


- - - -
## POST kata_option_set(id,name,value)
Set a theme (dark/light) or colour (on/off) or prediction (on/off) option.


- - - -
## POST kata_fork(id,index)
Creates a new kata whose starting files are a copy of the files in the kata with 
the given `id` at the given `index`. The new kata is *not* a fork in the git sense;
that is, it is *not* a 'deep' copy, the history of commits (one per test event)
that exist in the kata being forked are *not* copied.
- parameters 
  * **id:String**.
  * **index:int**
- returns 
  * the `id` of the created kata.
- example
  ```bash
  $ curl \
    --data '{"id":"dFg8Us", "index":23}' \
    --fail \    
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/kata_fork | jq .
  ```
  ```bash
  {
    "kata_fork": "a8gVRN"
  }
  ```


- - - -
# Probe API

## GET alive?
Liveness probe - is the service alive?  
- parameters
  * none
- result 
  * **true**
- example
  ```bash     
  $ curl --fail --silent --request GET https://${DOMAIN}:${PORT}/alive? | jq .
  ```
  ```bash
  {
    "alive?": true
  }
  ```


- - - -
## GET ready?
Readiness probe - is the service ready to handle requests?  
- parameters
  * none
- result 
  * **true** when the service is ready
  * **false** when the service is not ready
- example
  ```bash     
  $ curl --fail --silent --request GET https://${DOMAIN}:${PORT}/ready? | jq .
  ```
  ```bash
  {
    "ready?": false
  }
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
  $ curl --fail --silent --request GET https://${DOMAIN}:${PORT}/sha | jq .
  ```
  ```bash
  {
    "sha": "41d7e6068ab75716e4c7b9262a3a44323b4d1448"
  }
  ```


- - - -
## JSON in
- All methods pass their argument in a json hash in the http request body.
- If there are no arguments you can use `''` (which is the default for `curl --data`) instead of `'{}'`.


- - - -
## JSON out      
- All methods return a json hash in the http response body.
- If the method does not raise, a string key equals the method's name. eg
    ```bash
    $ curl --silent -X GET https://${DOMAIN}:${PORT}/ready? | jq .
    ```
    ```bash
    {
      "ready?": true
    }
    ```
- If the method raises an exception, a string key equals `"exception"`, with
    a json-hash as its value. eg
    ```bash
    $ curl --data 'not-json-hash' --silent -X GET https://${DOMAIN}:${PORT}/run | jq      
    ```
    ```bash
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
