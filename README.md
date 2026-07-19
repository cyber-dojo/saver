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

## [Cluster](docs/api.md#cluster)

A cluster is the umbrella over a multi Language-Test-Framework (LTF) practice: it offers 2..5
LTFs, holding one ordinary Group per LTF (its children).
A cluster is never joined directly; a joiner joins one of its child groups.

| Verb | Method | Description |
|------|--------|-------------|
| POST | [cluster_create](docs/api.md#post-cluster_create) | Creates a cluster from the given `manifest` and returns its id. |
| GET  | [cluster_manifest](docs/api.md#get-cluster_manifest) | Gets the manifest of the cluster with the given `id`: its `exercise` and its `children` (one per Language-Test-Framework). |
| GET  | [cluster_exists?](docs/api.md#get-cluster_exists) | Determines if a cluster with the given `id` exists. |


## [Group](docs/api.md#group)

A group is a shared practice for a single Language-Test-Framework: joiners join it,
each allocated a distinct avatar (Lion, Salmon, Bee, etc) and their own Kata of the group's exercise.
A group holds up to 64 katas, one per avatar. In a Cluster a group is one of the
children (one per LTF).

| Verb | Method | Description |
|------|--------|-------------|
| POST | [group_create](docs/api.md#post-group_create) | Creates a new group from the given `manifest` and returns its id. |
| GET  | [group_manifest](docs/api.md#get-group_manifest) | Gets the manifest used to create the group with the given `id`. |
| GET  | [group_exists?](docs/api.md#get-group_exists) | Determines if a group with the given `id` exists. |
| POST | [group_join](docs/api.md#post-group_join) | Creates a new kata in the group with the given `id` and returns the kata's id. |
| GET  | [group_joined](docs/api.md#get-group_joined) | Returns the kata-id and kata-events-summary keyed against the kata's avatar-index (0-63) for the katas that have joined a group. |
| POST | [group_fork](docs/api.md#post-group_fork) | Creates a new group whose starting files are a copy of the files in the kata with the given `id` at the given `index`. |


## [Kata](docs/api.md#kata)

A kata is one participant's practice: created from a manifest (an exercise for a
single Language-Test-Framework), it records every event as its own git commit -
the create, each file create/delete/rename/edit, and each test run with its
traffic-light colour (red, amber, green). Each avatar in a Group is a kata.

| Verb | Method | Description |
|------|--------|-------------|
| POST | [kata_create](docs/api.md#post-kata_create) | Creates a new kata from the given `manifest` and returns its id. |
| GET  | [kata_manifest](docs/api.md#get-kata_manifest) | Gets the manifest used to create the kata exercise with the given `id`. |
| GET  | [kata_exists?](docs/api.md#get-kata_exists) | Determines if a kata exercise with the given `id` exists. |
| GET  | [kata_events](docs/api.md#get-kata_events) | Gets the summary of all current events for the kata with the given `id`. |
| GET  | [katas_events](docs/api.md#get-katas_events) | Gets the full details for the kata events with the given `ids` and `indexes`. |
| GET  | [kata_event](docs/api.md#get-kata_event) | Gets the full details for the kata event whose kata has the given `id` whose event has the given `index`. |
| GET  | [kata_download](docs/api.md#get-kata_download) | Returns a gzipped tar archive of the kata's git repository, base64-encoded. |
| POST | [kata_file_create](docs/api.md#post-kata_file_create) | Records a new empty file being created in the browser. |
| POST | [kata_file_delete](docs/api.md#post-kata_file_delete) | Records a file being deleted in the browser. |
| POST | [kata_file_rename](docs/api.md#post-kata_file_rename) | Records a file being renamed in the browser. |
| POST | [kata_file_edit](docs/api.md#post-kata_file_edit) | Records a file edit event if any file content has changed since the last save. |
| POST | [kata_ran_tests](docs/api.md#post-kata_ran_tests) | Record a test event with no prediction. |
| POST | [kata_predicted_right](docs/api.md#post-kata_predicted_right) | Record a test event with a correct prediction. |
| POST | [kata_predicted_wrong](docs/api.md#post-kata_predicted_wrong) | Record a test event with an incorrect prediction. |
| POST | [kata_reverted](docs/api.md#post-kata_reverted) | Revert back to a previous traffic-light. |
| POST | [kata_checked_out](docs/api.md#post-kata_checked_out) | Checkout a traffic-light from a different avatar. |
| GET  | [kata_option_get](docs/api.md#get-kata_option_get) | Get a theme (dark/light) or colour (on/off) or prediction (on/off) option. |
| POST | [kata_option_set](docs/api.md#post-kata_option_set) | Set a theme (dark/light) or colour (on/off) or prediction (on/off) option. |
| POST | [kata_fork](docs/api.md#post-kata_fork) | Creates a new kata whose starting files are a copy of the files in the kata with the given `id` at the given `index`. |

## [ID](docs/api.md#id)

Find the full Cluster/Group/Kata information of any id.

| Verb | Method | Description |
|------|--------|-------------|
| GET  | [id_chain](docs/api.md#get-id_chain) | Returns the chain of ids from the given `id` up to its topmost containing entity, ordered bottom-to-top. |

## [Diff](docs/api.md#diff)

Compare a Kata's files between two event indexes.

| Verb | Method | Description |
|------|--------|-------------|
| GET  | [diff_lines](docs/api.md#get-diff_lines) | A diff of two sets of files (designated with `was_index` and `now_index`) from the kata with the given `id`. |
| GET  | [diff_summary](docs/api.md#get-diff_summary) | The same as `diff_lines` except the returned Hashes do *not* include the `"lines"` key. |

## [Probe](docs/api.md#probe)

Operational health checks, plus the git sha of the running image.

| Verb | Method | Description |
|------|--------|-------------|
| GET  | [alive?](docs/api.md#get-alive) | Liveness probe - is the service alive? |
| GET  | [ready?](docs/api.md#get-ready) | Readiness probe - is the service ready to handle requests? |
| GET  | [sha](docs/api.md#get-sha) | The git commit sha used to create the Docker image. |

# Screenshots

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
