
SHORT_SHA := $(shell git rev-parse HEAD | head -c7)
AWS_ACCOUNT_ID := 244531986313
AWS_REGION := eu-central-1
SERVICE_NAME := saver
IMAGE_NAME := ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${SERVICE_NAME}:${SHORT_SHA}


image_server:
	${PWD}/sh/build.sh

test_server:
	${PWD}/sh/run_tests_with_coverage.sh server

coverage_server:
	${PWD}/sh/check_coverage.sh server



lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

snyk-container:
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
