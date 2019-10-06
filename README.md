
[![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver)

# cyberdojo/saver docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Stores (key,value) data in a volume-mounted dir.

- - - -
API:
  * All methods are named in the http request path, and pass any
    arguments in the http request's json body.
  * All methods return a json hash in the http response's body.
    * If the method completes, a string key equals the method's name, with
      a value as documented below. eg
      ```bash
      curl \
        --data '{"key":"katas/N2/u8/9W"}' \
        --header 'Content-type: application/json' \
        -X POST \
        http://${IP_ADDRESS}:${PORT}/create \
          | jq      
      {
        "create": true
      }
      ```
    * If the method raises an exception, a string key equals ```exception```, with
      a json-hash as its value. eg
      ```bash
      curl \
        --data '{"key":"katas/N2/u8/9W/manifest.json","value":"{...}"}' \
        --header 'Content-type: application/json' \
        -X POST \
        http://${IP_ADDRESS}:${PORT}/append \
          | jq      
      {
        "exception": {
          "path": "/append",
          "body": "{\"key\":\"katas/N2/u8/9W/manifest.json\",\"value\":\"{...}\"}",
          "class": "SaverService",
          "message": "No space left on device @ fptr_finalize_flush - ......",
          "backtrace": [
            "/app/src/saver.rb:60:in close'",
            "/app/src/saver.rb:60:in open'",
            "/app/src/saver.rb:60:in append'",
            "...",
            "/usr/bin/rackup:23:in <main>'"
          ]
        }
      }
      ```

#
- [GET sha()](#get-sha)
- [GET ready?()](#get-ready)
- [GET alive?()](#get-alive)
- [POST create(key)](#post-createkey)
- [GET exists?(key)](#get-existskey)
- [POST write(key,value)](#post-writekeyvalue)
- [POST append(key,value)](#post-appendkeyvalue)
- [GET read(key)](#get-readkey)
- [POST batch(commands)](#get-batchcommands)

- - - -
# GET sha
The git commit sha used to create the Docker image.
- parameters
  * none
  ```json
  {}
  ```
- returns
  * The 40 character sha **String**.
  * eg
  ```json
  { "sha": "b28b3e13c0778fe409a50d23628f631f87920ce5" }
  ```

- - - -
# GET ready?
Used as a service readiness probe.
- parameters
  * none
  ```json
  {}
  ```
- returns
  * **true** if the service is ready
  ```json
  { "ready?": true }
  ```
  * **false** if the service is not ready
  ```json
  { "ready?": false }
  ```

- - - -
# GET alive?
Used as a service liveness probe.
- parameters
  * none
  ```json
  {}
  ```
- returns
  * **true**
  ```json
  { "alive?": true }
  ```

- - - -
# POST create(key)
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
# GET exists?(key)
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
# POST write(key,value)
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
# POST append(key,value)
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
# GET read(key)
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
# POST batch(commands)
Executes the given sequence of commands.
- parameter
  * **commands** an array of ```create```/```exists?```/```write```/```append```/```read``` commands
  ```json
  { "commands": [
    ["create","katas/e3/t6/A8"],
    ["exists?","katas/e3/t6/A8"],
    ["write","katas/e3/t6/A8/manifest.json","..."]
  ]}
  ```
- returns
  * An array containing the results of each command.
  ```json
  { "batch": [ true,true,true ]}
  ```

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
