
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
IMAGE_NAME := cyberdojo/saver:${SHORT_SHA}

.PHONY: image test snyk-container snyk-code

test:
	${PWD}/sh/run_tests_with_coverage.sh

snyk-container: image
	snyk container test ${IMAGE_NAME} \
        --file=Dockerfile \
		--sarif \
		--sarif-file-output=snyk.container.scan.json \
        --policy-path=.snyk

snyk-code:
	snyk code test \
		--sarif \
		--sarif-file-output=snyk.code.scan.json \
        --policy-path=.snyk

image:
	${PWD}/sh/build.sh