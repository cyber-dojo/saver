
[![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver)

# cyberdojo/saver docker image

- The source for the [cyberdojo/saver](https://hub.docker.com/r/cyberdojo/saver/tags) Docker image.
- A docker-containerized micro-service for [cyber-dojo](https://cyber-dojo.org).
- An http service, offering a simple file-system API.

API
- - - -
* [ GET group_exists?(id)](docs/api.md#get-group_existsid)
* [POST group_create(manifests,options)](docs/api.md#post-group_createmanifestsoptions)
* [ GET group_manifest(id)](docs/api.md#get-group_manifestid)
* [POST group_join(id,indexes)](docs/api.md#post-group_joinidindexes)
* [ GET group_joined(id)](docs/api.md#get-group_joinedid)
- - - -
* [ GET kata_exists?(id)](docs/api.md#get-kata_existsid)
* [POST kata_create(manifest,options)](docs/api.md#post-kata_createmanifestoptions)
* [ GET kata_manifest(id)](docs/api.md#get-kata_manifestid)
* [ GET kata_events(id)](docs/api.md#get-kata_eventsid)
* [ GET kata_event(id,index)](docs/api.md#get-kata_eventidindex)
* [ GET katas_events(ids,indexs)](docs/api.md#get-katas_eventsidsindexes)
* [POST kata_ran_tests(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_ran_testsidindexfilesstdoutstderrstatussummary)
* [POST kata_predicted_right(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_predicted_rightidindexfilesstdoutstderrstatussummary)
* [POST kata_predicted_wrong(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_predicted_wrongidindexfilesstdoutstderrstatussummary)
* [POST kata_reverted(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_revertedidindexfilesstdoutstderrstatussummary)
* [POST kata_checked_out(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_checked_outidindexfilesstdoutstderrstatussummary)
* [ GET kata_option_get(id,name)](docs/api.md#get-kata_option_getidname)
* [POST kata_option_set(id,name,value)](docs/api.md#post-kata_option_setidnamevalue)
- - - -
- [GET ready?](docs/api.md#get-ready)
- [GET alive?](docs/api.md#get-alive)  
- [GET sha](docs/api.md#get-sha)
- - - -
- [POST assert(command)](docs/api.md#post-assertcommand)
- [POST assert_all(commands)](docs/api.md#post-assert_allcommands)
- - - -
- [POST run(command)](docs/api.md#post-runcommand)
- [POST run_all](docs/api.md#post-run_allcommands)
- [POST run_until_true](docs/api.md#post-run_until_truecommands)
- [POST run_until_false](docs/api.md#post-run_until_falsecommands)

- - - -
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
