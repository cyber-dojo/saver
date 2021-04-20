
[![CircleCI](https://circleci.com/gh/cyber-dojo/saver.svg?style=svg)](https://circleci.com/gh/cyber-dojo/saver)

# cyberdojo/saver docker image

- The source for the [cyberdojo/saver](https://hub.docker.com/r/cyberdojo/saver/tags) Docker image.
- A docker-containerized micro-service for [cyber-dojo](https://cyber-dojo.org).
- An http service, offering a simple file-system API.

API
- - - -
- [POST assert(command)](docs/api.md#post-assertcommand)
- [POST assert_all(commands)](docs/api.md#post-assert_allcommands)
- - - -
- [POST run(command)](docs/api.md#post-runcommand)
- [POST run_all](docs/api.md#post-run_allcommands)
- [POST run_until_true](docs/api.md#post-run_until_truecommands)
- [POST run_until_false](docs/api.md#post-run_until_falsecommands)
- - - -
- [GET ready?](docs/api.md#get-ready)
- [GET alive?](docs/api.md#get-alive)  
- [GET sha](docs/api.md#get-sha)

- - - -
![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)
