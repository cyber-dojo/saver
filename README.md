[![Github Action (main)](https://github.com/cyber-dojo/saver/actions/workflows/main.yml/badge.svg?branch=main)](https://github.com/cyber-dojo/saver/actions)

- A [docker-containerized](https://hub.docker.com/r/cyberdojo/saver/tags) microservice for [https://cyber-dojo.org](http://cyber-dojo.org).
- An HTTP [Ruby](https://www.ruby-lang.org) [Sinatra](http://sinatrarb.com/) web service, offering a Group/Kata model+persistence API.
- Demonstrates a [Kosli](https://www.kosli.com/) instrumented [GitHub CI workflow](https://app.kosli.com/cyber-dojo/flows/saver-ci/trails/) 
  deploying, with Continuous Compliance, to its [staging](https://app.kosli.com/cyber-dojo/environments/aws-beta/snapshots/) AWS environment.
- Deployment to its [production](https://app.kosli.com/cyber-dojo/environments/aws-prod/snapshots/) AWS environment is via a separate [promotion workflow](https://github.com/cyber-dojo/aws-prod-co-promotion).
- Uses attestation patterns from https://www.kosli.com/blog/using-kosli-attest-in-github-action-workflows-some-tips/

# Development

There are two sets of tests:
- server: these run from inside the saver container
- client: these run from outside the saver container, making api calls only 

```bash
# Build the images
$ make {image_server|image_client}

# Run all tests
$ make {test_server|test_client}

# Run only tests whose id starts with Sp5
$ make {test_server|test_client} tid=Sp5

# Check test metrics
$ make {metrics_test_server|metrics_test_client}

# Check coverage metrics
$ make {metrics_coverage_server|metrics_coverage_client}
```

# API

## [Probe API](docs/api.md#probe-api)

* [GET alive?](docs/api.md#get-alive)  
* [GET ready?](docs/api.md#get-ready)
* [GET sha](docs/api.md#get-sha)


## [ID API](docs/api.md#id-api)

* [GET id_chain(id)](docs/api.md#get-id_chainid)


## [Cluster API](docs/api.md#cluster-api)

* [POST cluster_create(manifest)](docs/api.md#post-cluster_createmanifest)
* [GET cluster_manifest(id)](docs/api.md#get-cluster_manifestid)
* [GET cluster_exists?(id)](docs/api.md#get-cluster_existsid)


## [Group API](docs/api.md#group-api)

* [POST group_create(manifest)](docs/api.md#post-group_createmanifest)
* [GET group_manifest(id)](docs/api.md#get-group_manifestid)
* [GET group_exists?(id)](docs/api.md#get-group_existsid)
* [POST group_join(id,indexes)](docs/api.md#post-group_joinidindexes)
* [GET group_joined(id)](docs/api.md#get-group_joinedid)
* [POST group_fork(id,index)](docs/api.md#post-group_forkidindex)


## [Kata API](docs/api.md#kata-api)

* [POST kata_create(manifest)](docs/api.md#post-kata_createmanifest)
* [GET kata_manifest(id)](docs/api.md#get-kata_manifestid)
* [GET kata_exists?(id)](docs/api.md#get-kata_existsid)
* [GET kata_events(id)](docs/api.md#get-kata_eventsid)
* [GET katas_events(ids,indexes)](docs/api.md#get-katas_eventsidsindexes)
* [GET kata_event(id,index)](docs/api.md#get-kata_eventidindex)
* [GET kata_download(id)](docs/api.md#get-kata_downloadid)
* [POST kata_file_create(id,files,filename,laptop_id)](docs/api.md#post-kata_file_createidfilesfilenamelaptop_id)
* [POST kata_file_delete(id,files,filename,laptop_id)](docs/api.md#post-kata_file_deleteidfilesfilenamelaptop_id)
* [POST kata_file_rename(id,files,old_filename,new_filename,laptop_id)](docs/api.md#post-kata_file_renameidfilesold_filenamenew_filenamelaptop_id)
* [POST kata_file_edit(id,files,laptop_id)](docs/api.md#post-kata_file_editidfileslaptop_id)
* [POST kata_ran_tests(id,files,stdout,stderr,status,summary,laptop_id)](docs/api.md#post-kata_ran_testsidfilesstdoutstderrstatussummarylaptop_id)
* [POST kata_predicted_right(id,files,stdout,stderr,status,summary,laptop_id)](docs/api.md#post-kata_predicted_rightidfilesstdoutstderrstatussummarylaptop_id)
* [POST kata_predicted_wrong(id,files,stdout,stderr,status,summary,laptop_id)](docs/api.md#post-kata_predicted_wrongidfilesstdoutstderrstatussummarylaptop_id)
* [POST kata_reverted(id,files,stdout,stderr,status,summary,laptop_id)](docs/api.md#post-kata_revertedidfilesstdoutstderrstatussummarylaptop_id)
* [POST kata_checked_out(id,files,stdout,stderr,status,summary,laptop_id)](docs/api.md#post-kata_checked_outidfilesstdoutstderrstatussummarylaptop_id)
* [GET kata_option_get(id,name)](docs/api.md#get-kata_option_getidname)
* [POST kata_option_set(id,name,value)](docs/api.md#post-kata_option_setidnamevalue)
* [POST kata_fork(id,index)](docs/api.md#post-kata_forkidindex)


## [Diff API](docs/api.md#diff-api)

* [GET diff_lines(id,was_index,now_index)](docs/api.md#get-diff_linesidwas_indexnow_index)
* [GET diff_summary(id,was_index,now_index)](docs/api.md#get-diff_summaryidwas_indexnow_index)


# Screenshots

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
