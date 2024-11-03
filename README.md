[![Github Action (main)](https://github.com/cyber-dojo/saver/actions/workflows/main.yml/badge.svg)](https://github.com/cyber-dojo/saver/actions)

- A [docker-containerized](https://hub.docker.com/r/cyberdojo/saver/tags) microservice for [https://cyber-dojo.org](http://cyber-dojo.org).
- An HTTP [Ruby](https://www.ruby-lang.org) [Sinatra](http://sinatrarb.com/) web service, offering a Group/Kata model+persistence API.
- Demonstrates a [Kosli](https://www.kosli.com/) instrumented [GitHub CI workflow](https://app.kosli.com/cyber-dojo/flows/saver-ci/trails/) 
  deploying, with Continuous Compliance, to [staging](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/) and [production](https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/) AWS environments.
- Uses patterns from https://www.kosli.com/blog/using-kosli-attest-in-github-action-workflows-some-tips/

# Development

There are two sets of tests:
- server: these run from inside the saver container
- client: these run from outside the saver container, making api calls only 

```bash
# To build the images
$ make {image_server|image_client}

# To run all tests
$ make {test_server|test_client}

# To run only specific tests
$ ./bin/run_tests.sh {-h|--help}
$ ./bin/run_tests.sh server Ks366

# To check coverage metrics
$ make {coverage_server|coverage_client}
```

# API
## Group

* [POST group_create(manifest)](docs/api.md#post-group_createmanifest)
* [GET group_exists?(id)](docs/api.md#get-group_existsid)
* [POST group_join(id,indexes)](docs/api.md#post-group_joinidindexes)
* [GET group_joined(id)](docs/api.md#get-group_joinedid)
* [GET group_manifest(id)](docs/api.md#get-group_manifestid)
* [POST group_fork(id,index)](docs/api.md#post-group_forkidindex)

## Kata

* [POST kata_create(manifest)](docs/api.md#post-kata_createmanifest)
* [GET kata_exists?(id)](docs/api.md#get-kata_existsid)
* [GET kata_events(id)](docs/api.md#get-kata_eventsid)
* [GET kata_event(id,index)](docs/api.md#get-kata_eventidindex)
* [GET katas_events(ids,indexes)](docs/api.md#get-katas_eventsidsindexes)
* [GET kata_manifest(id)](docs/api.md#get-kata_manifestid)
* [POST kata_ran_tests(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_ran_testsidindexfilesstdoutstderrstatussummary)
* [POST kata_predicted_right(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_predicted_rightidindexfilesstdoutstderrstatussummary)
* [POST kata_predicted_wrong(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_predicted_wrongidindexfilesstdoutstderrstatussummary)
* [POST kata_reverted(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_revertedidindexfilesstdoutstderrstatussummary)
* [POST kata_checked_out(id,index,files,stdout,stderr,status,summary)](docs/api.md#post-kata_checked_outidindexfilesstdoutstderrstatussummary)
* [GET kata_option_get(id,name)](docs/api.md#get-kata_option_getidname)
* [POST kata_option_set(id,name,value)](docs/api.md#post-kata_option_setidnamevalue)
* [POST kata_fork(id,index)](docs/api.md#post-kata_forkidindex)


## Probe

- [GET alive?](docs/api.md#get-alive)  
- [GET ready?](docs/api.md#get-ready)
- [GET sha](docs/api.md#get-sha)


![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
