
[![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver)

# cyberdojo/saver docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Stores (key,value) data in a volume-mounted dir.

- - - -
API:
  * All methods receive a json hash.
    * The hash contains any method arguments as key-value pairs.
  * All methods return a json hash.
    * If the method completes, a key equals the method's name.
    * If the method raises an exception, a key equals "exception".

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
## GET sha
The git commit sha used to create the Docker image.
- returns
  * The 40 character sha string.
  * eg
  ```json
  { "sha": "b28b3e13c0778fe409a50d23628f631f87920ce5" }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
# GET ready?
Useful as a readiness probe.
- returns
  * **true** if the service is ready
  ```json
  { "ready?": true }
  ```
  * **false** if the service is not ready
  ```json
  { "ready?": false }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
# GET alive?
Useful as a liveness probe.
- returns
  * **true**
  ```json
  { "alive?": true }
  ```
- parameters
  * none
  ```json
  {}
  ```

- - - -
## POST create(key)

- - - -
## GET exists?(key)

- - - -
## POST write(key,value)

- - - -
## POST append(key,value)

- - - -
## GET read(key)

- - - -
## POST batch(commands)

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
