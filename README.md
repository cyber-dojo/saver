
[![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver)

# cyberdojo/saver docker image

- The source for the [cyberdojo/saver](https://hub.docker.com/r/cyberdojo/saver/tags) Docker image.
- A docker-containerized micro-service for [cyber-dojo](https://cyber-dojo.org).
- An http service, offering a group/kata model+persistence API.

Development
-----------
To build the images and run the containers:
```bash
$ ./build.sh && ./up.sh && ./wait.sh
````

To run the tests:
```bash
$ ./test
```

After a commit you need to build/up/wait again.



API
---
* [PUT group_create(manifests,options)](docs/api.md#post-group_createmanifestsoptions)
* [GET group_exists?(id)](docs/api.md#get-group_existsid)
* [PUT group_join(id,indexes)](docs/api.md#post-group_joinidindexes)
* [GET group_joined(id)](docs/api.md#get-group_joinedid)
* [GET group_manifest(id)](docs/api.md#get-group_manifestid)
- - - -
* [PUT kata_create(manifest,options)](docs/api.md#post-kata_createmanifestoptions)
* [GET kata_exists?(id)](docs/api.md#get-kata_existsid)
* [GET kata_events(id)](docs/api.md#get-kata_eventsid)
* [GET kata_event(id,index)](docs/api.md#get-kata_eventidindex)
* [GET katas_events(ids,indexs)](docs/api.md#get-katas_eventsidsindexes)
* [GET kata_manifest(id)](docs/api.md#get-kata_manifestid)
* [PUT kata_ran_tests(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_ran_testsidindexfilesstdoutstderrstatussummary)
* [PUT kata_predicted_right(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_predicted_rightidindexfilesstdoutstderrstatussummary)
* [PUT kata_predicted_wrong(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_predicted_wrongidindexfilesstdoutstderrstatussummary)
* [PUT kata_reverted(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_revertedidindexfilesstdoutstderrstatussummary)
* [PUT kata_checked_out(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_checked_outidindexfilesstdoutstderrstatussummary)
* [GET kata_option_get(id,name)](docs/api.md#get-kata_option_getidname)
* [PUT kata_option_set(id,name,value)](docs/api.md#post-kata_option_setidnamevalue)
- - - -
- [GET alive?](docs/api.md#get-alive)  
- [GET ready?](docs/api.md#get-ready)
- [GET sha](docs/api.md#get-sha)
- - - -
deprecated
- [POST assert(command)](docs/api.md#post-assertcommand)
- [POST assert_all(commands)](docs/api.md#post-assert_allcommands)
- - - -
- [POST run(command)](docs/api.md#post-runcommand)
- [POST run_all](docs/api.md#post-run_allcommands)
- [POST run_until_false](docs/api.md#post-run_until_falsecommands)
- [POST run_until_true](docs/api.md#post-run_until_truecommands)

- - - -
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
