
[![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver)

# cyberdojo/saver docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Stores (key,value) data in a volume-mounted dir.

- - - -
API:
  * All methods are named in the http request path, and pass any
    arguments in the http request's json body. eg
    ```bash
    curl \
      -H 'Content-type: application/json' \
      -X PUT \
      -d '{"key":"katas/N2/u8/9W"}' \
      http://${IP_ADDRESS}:${PORT}/create
    ```
  * All methods return a json hash in the http response's body.
    * If the method completes, a key equals the method's name, with
      a value as documented below (usually ```true```/```false```). eg
      ```json
      { "create": true }
      ```
    * If the method raises an exception, a key equals "exception", with
      a json-string as its value. eg
      ```json
      { "exception": "{\"path\":\"...\",\"class\":\"...\",\"message\":\"...\"}" }
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
# POST create(key)
Creates **key** to allow subsequent calls to ```write``` and ```append```.
Corresponds to ```mkdir -p ${key}``` in a file-system.
- returns
  * **true** if there has _not_ been a previous call to ```create``` with the given **key**
  ```json
  { "create": true }
  ```
  * **false** if there _has_ been a previous call to ```create``` with the given **key**
  ```json
  { "create": false }
  ```
- parameters
  * **key** a String specifying a dir-like path, eg
  ```json
  { "key": "katas/N2/u8/9W" }
  ```

- - - -
# GET exists?(key)
Determines if there has been a previous call to create(key).
Corresponds to ```[ -d ${key} ]``` in a file-system.
- returns
  * **true** if there _has_ been a previous call to ```create``` with the given **key**
  ```json
  { "exists?": true }
  ```
  * **false** if there has _not_ been a previous call to ```create``` with the given **key**
  ```json
  { "exists?": false }
  ```
- parameters
  * **key** a String, eg
  ```json
  { "key": "katas/N2/u8/9W" }
  ```

- - - -
# POST write(key,value)

- - - -
# POST append(key,value)

- - - -
# GET read(key)

- - - -
# POST batch(commands)

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
