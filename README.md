
[![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver)

- The source for the [cyberdojo/saver](https://hub.docker.com/r/cyberdojo/saver/tags) Docker image.
- A docker-containerized micro-service for [cyber-dojo](https://cyber-dojo.org).
- An HTTP [Ruby](https://www.ruby-lang.org) [Sinatra](http://sinatrarb.com/) web service, offering a Group/Kata model+persistence API.

Development
-----------
To build the images, bring up the containers, and wait till they are alive and healthy:
```bash
$ ./build.sh && ./down.sh && ./up.sh && ./wait.sh
````

To run the tests:
```bash
$ ./test.sh --help
```
```
Use: ./test.sh [server|client] [ID...]

No options runs all server tests, then all client tests

Options:
   server      run from inside the server container (unit tests)
   client      run from inside the client container (integration tests)
   ID...       run only the tests matching the given IDs
   -h|--help   show this help
```

* The [build.sh](build.sh) script (re)creates [docker-compose.yml](docker-compose.yml)
* In [docker-compose.yml](docker-compose.yml), the source and test dirs are volume-mounted over their image counterparts.
* These overlays keeps the dev-cycle fast by reducing the need to build/down/up/wait.
* You need to build/down/up/wait when:
  * You change a Dockerfile
  * You change a web server's config (there is no auto-reloading)


Group
-----
* [POST group_create(manifests,options)](docs/api.md#post-group_createmanifestsoptions)
* [GET group_exists?(id)](docs/api.md#get-group_existsid)
* [POST group_join(id,indexes)](docs/api.md#post-group_joinidindexes)
* [GET group_joined(id)](docs/api.md#get-group_joinedid)
* [GET group_manifest(id)](docs/api.md#get-group_manifestid)


Kata
----
* [POST kata_create(manifest,options)](docs/api.md#post-kata_createmanifestoptions)
* [GET kata_exists?(id)](docs/api.md#get-kata_existsid)
* [GET kata_events(id)](docs/api.md#get-kata_eventsid)
* [GET kata_event(id,index)](docs/api.md#get-kata_eventidindex)
* [GET katas_events(ids,indexs)](docs/api.md#get-katas_eventsidsindexes)
* [GET kata_manifest(id)](docs/api.md#get-kata_manifestid)
* [POST kata_ran_tests(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_ran_testsidindexfilesstdoutstderrstatussummary)
* [POST kata_predicted_right(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_predicted_rightidindexfilesstdoutstderrstatussummary)
* [POST kata_predicted_wrong(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_predicted_wrongidindexfilesstdoutstderrstatussummary)
* [POST kata_reverted(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_revertedidindexfilesstdoutstderrstatussummary)
* [POST kata_checked_out(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_checked_outidindexfilesstdoutstderrstatussummary)
* [GET kata_option_get(id,name)](docs/api.md#get-kata_option_getidname)
* [POST kata_option_set(id,name,value)](docs/api.md#post-kata_option_setidnamevalue)


Probe
-----
- [GET alive?](docs/api.md#get-alive)  
- [GET ready?](docs/api.md#get-ready)
- [GET sha](docs/api.md#get-sha)

- - - -
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
