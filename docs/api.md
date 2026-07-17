# API 

- [(JSON-in)](#json-in) All methods pass their argument in a json hash in the HTTP request body.
- [(JSON-out)](#json-out) All methods return a json hash in the HTTP response body.
- GET is used for queries.
- POST is used for modifiers.
- Paths are *not* REST-ful.


- - - -
# Cluster API

A cluster is the umbrella over a multi-LTF practice: it offers 2..4
language-test-frameworks, holding one ordinary group per LTF (its children).
A cluster is never joined directly; a joiner joins one of its child groups.

## POST cluster_create(manifest)
Creates a cluster from the given `manifest` and returns its id.
The manifest holds the group-wide `exercise` and an `ltfs` array (2..4 per-LTF
group manifests). For each ltf a child group is created, carrying a `cluster_id`
back-pointer, and the cluster references the children.
- parameters
  * **manifest:Hash** with `exercise:String` and `ltfs:Array[Hash]`, the 2..4
    per-LTF group manifests (as built by
    [creator](https://github.com/cyber-dojo/creator)).
- returns
  * the `id` of the created cluster.
  * status 400 if `ltfs` does not hold 2..4 entries.
- example
  ```bash
  $ curl \
    --data '{"manifest":{"exercise":"Tennis","ltfs":[...]}}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request POST \
      https://${DOMAIN}:${PORT}/cluster_create | jq .
  ```
  ```bash
  {
    "cluster_create": "dFg8Us"
  }
  ```


- - - -
## GET cluster_manifest(id)
Gets the manifest of the cluster with the given `id`: its `exercise` and its
`children` (one per LTF, each `{ltf_display_name, group_id}`).
- parameters
  * **id:String**. The cluster id.
- returns
  * the manifest of the cluster with the given `id`.
- example
  ```bash
  $ curl \
    --data '{"id":"dFg8Us"}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/cluster_manifest | jq .
  ```
  ```bash
  {
    "cluster_manifest": {
      "id": "dFg8Us",
      "exercise": "Tennis",
      "children": [
        { "ltf_display_name": "Python, unittest", "group_id": "g1AbCd" },
        { "ltf_display_name": "Ruby, MiniTest",   "group_id": "g2EfGh" }
      ]
    }
  }
  ```


- - - -
## GET cluster_exists?(id)
Determines if a cluster with the given `id` exists.
- parameters
  * **id:String**. The cluster id.
- returns
  * `true` if a cluster with the given `id` exists, otherwise `false`.
- example
  ```bash
  $ curl \
    --data '{"id":"dFg8Us"}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/cluster_exists? | jq .
  ```
  ```bash
  {
    "cluster_exists?": true
  }
  ```


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
## POST group_join(id, indexes)
Creates a new kata in the group with the given `id` and returns the kata's id.
- parameters 
  * **id:String**. The group id.
  * **indexes:Array[int]** (optional). The candidate avatar indexes (from 0..63)
    in preference order. The first index not already taken in the group is
    allocated. Defaults to a shuffled 0..63. Pass a custom order to influence
    which avatar a joiner gets. For example, in a cluster, list the avatars not
    yet used elsewhere in the cluster first, so avatars stay distinct across the
    cluster's groups.
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
## POST kata_file_create(id,files,filename)
Records a new empty file being created in the browser. If any existing file has been edited since the last save, that edit is recorded first as a `file_edit` event.
- parameters
  * **id:String**. The kata id.
  * **files:Hash**. The current files (the new `filename` is not yet present).
  * **filename:String**. The name of the file being created.
- returns
  * the next event index (the saver assigns it).
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","files":{...},"filename":"utils.sh"}' \
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
## POST kata_file_delete(id,files,filename)
Records a file being deleted in the browser. If any existing file has been edited since the last save, that edit is recorded first as a `file_edit` event.
- parameters
  * **id:String**. The kata id.
  * **files:Hash**. The current files (the `filename` to delete is still present).
  * **filename:String**. The name of the file being deleted.
- returns
  * the next event index (the saver assigns it).
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","files":{...},"filename":"utils.sh"}' \
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
## POST kata_file_rename(id,files,old_filename,new_filename)
Records a file being renamed in the browser. If any existing file has been edited since the last save, that edit is recorded first as a `file_edit` event.
- parameters
  * **id:String**. The kata id.
  * **files:Hash**. The current files (`old_filename` is present; `new_filename` is not yet present).
  * **old_filename:String**. The current name of the file.
  * **new_filename:String**. The new name of the file.
- returns
  * the next event index (the saver assigns it).
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","files":{...},"old_filename":"utils.sh","new_filename":"helpers.sh"}' \
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
## POST kata_file_edit(id,files)
Records a file edit event if any file content has changed since the last save. If no file has changed, no event is recorded and the next event index is returned unchanged.
- parameters
  * **id:String**. The kata id.
  * **files:Hash**. The current files.
- returns
  * the next event index (the saver assigns it; unchanged if no file was edited).
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","files":{...}}' \
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
## POST kata_ran_tests(id,files,stdout,stderr,status,summary)
Record a test event with no prediction.
- parameters 
  * **id:String**. The kata id.
  * **files:Hash**. The files which created `stdout`,`stderr`,`status` in the same format as [kata_event](#get-kata_eventidindex)
  * **stdout:Hash**. The stdout produced from `files`, in the same format as [kata_event](#get-kata_eventidindex)
  * **stderr:Hash**. The stderr produced from `files`, in the same format as [kata_event](#get-kata_eventidindex)
  * **status:String**. The status produced from `files`, in the same format as [kata_event](#get-kata_eventidindex)
  * **summary:Hash**. Extra event data to store, eg `duration`,`time`,`colour`


- - - -
## POST kata_predicted_right(id,files,stdout,stderr,status,summary)
Record a test event with a correct prediction.


- - - -
## POST kata_predicted_wrong(id,files,stdout,stderr,status,summary)
Record a test event with an incorrect prediction.


- - - -
## POST kata_reverted(id,files,stdout,stderr,status,summary)
Revert back to a previous traffic-light.


- - - -
## POST kata_checked_out(id,files,stdout,stderr,status,summary)
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
# ID API

- - - -
## GET id_chain(id)
Returns the chain of ids from the given `id` up to its topmost containing entity,
ordered bottom-to-top as `[{type,id}, ...]` where `type` is `kata`, `group` or
`cluster`. The first entry is the given id; the last entry's id is the topmost.
Lets a caller resolve any id up to the practice it belongs to (eg a kata up to
its cluster).
- parameters
  * **id:String**. A kata, group or cluster id.
- returns
  * the id chain. A solo kata returns just itself; a kata in a cluster returns
    its kata, then group, then cluster.
- example
  ```bash
  $ curl \
    --data '{"id":"5rTJv5"}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/id_chain | jq .
  ```
  ```bash
  {
    "id_chain": [
      { "type": "kata",    "id": "5rTJv5" },
      { "type": "group",   "id": "g1AbCd" },
      { "type": "cluster", "id": "dFg8Us" }
    ]
  }
  ```


- - - -
# Diff API

## GET diff_lines(id,was_index,now_index)
A diff of two sets of files (designated with `was_index` and `now_index`) from the kata with the given `id`.
Every line of every file is returned - not just the changed lines with a few unchanged lines either side
as a normal `git diff` would give. Unchanged files and files renamed with identical content are also included.
- parameters
  * **id:String**. The kata id.
  * **was_index:Integer**. The event index of the first set of files.
  * **now_index:Integer**. The event index of the second set of files.
- returns
  * an Array of Hashes, one per file. Each Hash has the following keys:
    - `"type"` - one of `"created"`, `"deleted"`, `"renamed"`, `"changed"`, `"unchanged"`.
    - `"old_filename"` - the filename at `was_index`, or `null` if `"type"` is `"created"`.
    - `"new_filename"` - the filename at `now_index`, or `null` if `"type"` is `"deleted"`.
    - `"lines"` - an Array of Hashes, each with `"type"` (`"added"`, `"deleted"`, `"same"`, or `"section"`).
    - `"line_counts"` - a Hash with `"added"`, `"deleted"`, and `"same"` counts.
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","was_index":3,"now_index":4}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/diff_lines | jq .
  ```
  ```bash
  {
    "diff_lines": [
      {
        "type": "changed",
        "old_filename": "hiker.py",
        "new_filename": "hiker.py",
        "lines": [
          { "type": "same",    "line": "class Hiker:", "number": 1 },
          { "type": "section", "index": 0 },
          { "type": "deleted", "line": "    pass",     "number": 2 },
          { "type": "added",   "line": "    def answer(self):", "number": 2 },
          { "type": "added",   "line": "        return 42",    "number": 3 }
        ],
        "line_counts": { "added": 2, "deleted": 1, "same": 1 }
      },
      ...
    ]
  }
  ```


- - - -
## GET diff_summary(id,was_index,now_index)
The same as `diff_lines` except the returned Hashes do *not* include the `"lines"` key.
- parameters
  * **id:String**. The kata id.
  * **was_index:Integer**. The event index of the first set of files.
  * **now_index:Integer**. The event index of the second set of files.
- returns
  * an Array of Hashes with `"type"`, `"old_filename"`, `"new_filename"`, and `"line_counts"` (no `"lines"`).
- example
  ```bash
  $ curl \
    --data '{"id":"4ScKVJ","was_index":3,"now_index":4}' \
    --fail \
    --header 'Content-type: application/json' \
    --silent \
    --request GET \
      https://${DOMAIN}:${PORT}/diff_summary | jq .
  ```
  ```bash
  {
    "diff_summary": [
      {
        "type": "changed",
        "old_filename": "hiker.py",
        "new_filename": "hiker.py",
        "line_counts": { "added": 2, "deleted": 1, "same": 1 }
      },
      ...
    ]
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
