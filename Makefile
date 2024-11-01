
all_server: image_server test_server coverage_server

image_server:
	${PWD}/bin/build_image.sh server

test_server:
	${PWD}/bin/run_tests.sh server

coverage_server:
	${PWD}/bin/check_coverage.sh server


all_client: image_client test_client coverage_client

image_client:
	${PWD}/bin/build_image.sh client

test_client:
	${PWD}/bin/run_tests.sh client

coverage_client:
	${PWD}/bin/check_coverage.sh client


rubocop-lint:
	docker run --rm --volume "${PWD}:/app" cyberdojo/rubocop --raise-cop-error

snyk-container-scan:
	${PWD}/bin/snyk_container_scan.sh

snyk-code-scan:
	${PWD}/bin/snyk_code_scan.sh
