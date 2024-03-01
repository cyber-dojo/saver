
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := cyberdojo/saver:${SHORT_SHA}

.PHONY: all test snyk image

all: image test snyk

test:
	${PWD}/sh/run_tests_with_coverage.sh

snyk: image
	snyk container test ${IMAGE_NAME}
        --file=Dockerfile
        --json-file-output=snyk.json
        --policy-path=.snyk

image:
	${PWD}/sh/build.sh