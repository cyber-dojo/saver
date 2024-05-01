
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
AWS_ACCOUNT_ID := 244531986313
AWS_REGION := eu-central-1
SERVICE_NAME := saver
IMAGE_NAME := ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SERVICE_NAME}:${SHORT_SHA}

.PHONY: image test snyk-container snyk-code

test: image
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