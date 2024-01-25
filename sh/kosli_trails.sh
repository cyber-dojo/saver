#!/usr/bin/env bash
set -Eeu

export KOSLI_FLOW=saver
export KOSLI_ORG=cyber-dojo-trails
# KOSLI_API_TOKEN is set in CI
# KOSLI_API_TOKEN_STAGING is set in CI
# KOSLI_HOST_STAGING is set in CI
# KOSLI_HOST_PRODUCTION is set in CI
# SNYK_TOKEN is set in CI

# - - - - - - - - - - - - - - - - - - -
kosli_begin_trail()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  kosli create flow "${KOSLI_FLOW}" \
    --description="Group/Kata model+persistence" \
    --host="${hostname}" \
    --api-token="${api_token}" \
    --template-file="$(repo_root)/.kosli.yml" \
    --visibility=public

  kosli begin trail "${GITHUB_SHA}" \
    --host="${hostname}" \
    --api-token="${api_token}" \
    --repo-root="$(repo_root)"
}

# - - - - - - - - - - - - - - - - - - -
kosli_attest_artifact()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  pushd "$(root_dir)"  # So we don't need --repo-root flag

  kosli attest artifact "$(artifact_name)" \
    --artifact-type=docker \
    --host="${hostname}" \
    --api-token="${api_token}" \
    --name=saver \
    --trail="${GITHUB_SHA}"

  popd
}

# - - - - - - - - - - - - - - - - - - -
kosli_attest_coverage_evidence()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  #  --description="server & client branch-coverage reports" \

  kosli attest generic "$(artifact_name)" \
    --artifact-type=docker \
    --name=saver.branch-coverage \
    --user-data="$(coverage_json_path)" \
    --host="${hostname}" \
    --api-token="${api_token}" \
    --trail="${GITHUB_SHA}"

}

# - - - - - - - - - - - - - - - - - - -
kosli_attest_snyk_evidence()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  kosli attest snyk "$(artifact_name)" \
    --artifact-type=docker \
    --host="${hostname}" \
    --api-token="${api_token}" \
    --name=saver.snyk-scan \
    --scan-results="$(root_dir)/snyk.json" \
    --trail="${GITHUB_SHA}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_assert_artifact()
{
  local -r hostname="${1}"
  local -r api_token="${2}"

  kosli assert artifact "$(artifact_name)" \
    --artifact-type=docker \
    --host="${hostname}" \
    --api-token="${api_token}"
}

# - - - - - - - - - - - - - - - - - - -
kosli_expect_deployment()
{
  local -r environment="${1}"
  local -r hostname="${2}"
  local -r api_token="${3}"

  # In .github/workflows/main.yml deployment is its own job
  # and the image must be present to get its sha256 fingerprint.
  docker pull "$(artifact_name)"

  kosli expect deployment "$(artifact_name)" \
    --artifact-type=docker \
    --description="Deployed to ${environment} in Github Actions pipeline" \
    --environment="${environment}" \
    --host="${hostname}" \
    --api-token="${api_token}"
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_begin_trail()
{
  if on_ci; then
    kosli_begin_trail "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_begin_trail "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_attest_artifact()
{
  if on_ci; then
    kosli_attest_artifact "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_attest_artifact "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_attest_coverage_evidence()
{
  if on_ci; then
    write_coverage_json
    kosli_attest_coverage_evidence "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_attest_coverage_evidence "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_attest_snyk_scan_evidence()
{
  if on_ci; then
    set +e
    snyk container test "$(artifact_name)" \
      --json-file-output="$(root_dir)/snyk.json" \
      --policy-path="$(root_dir)/.snyk"
    set -e

    kosli_attest_snyk_evidence "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_attest_snyk_evidence "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}

# - - - - - - - - - - - - - - - - - - -
on_ci_kosli_assert_artifact()
{
  if on_ci; then
    kosli_assert_artifact "${KOSLI_HOST_STAGING}"    "${KOSLI_API_TOKEN_STAGING}"
    kosli_assert_artifact "${KOSLI_HOST_PRODUCTION}" "${KOSLI_API_TOKEN}"
  fi
}


# - - - - - - - - - - - - - - - - - - -
artifact_name()
{
  source "$(root_dir)/sh/echo_versioner_env_vars.sh"
  export $(echo_versioner_env_vars)
  echo "${CYBER_DOJO_SAVER_IMAGE}:${CYBER_DOJO_SAVER_TAG}"
}

# - - - - - - - - - - - - - - - - - - -
repo_root()
{
  git rev-parse --show-toplevel
}

root_dir()
{
  git rev-parse --show-toplevel
}
export -f root_dir

# - - - - - - - - - - - - - - - - - - -
on_ci()
{
  [ -n "${CI:-}" ]
}

# - - - - - - - - - - - - - - - - - - -
write_coverage_json()
{
  {
    echo '{ "server":'
    cat "$(root_dir)/tmp/coverage/server/coverage.json"
    echo ', "client":'
    cat "$(root_dir)/tmp/coverage/client/coverage.json"
    echo '}'
  } > "$(coverage_json_path)"
}

# - - - - - - - - - - - - - - - - - - -
coverage_json_path()
{
  echo "$(root_dir)/tmp/evidence.json"
}
