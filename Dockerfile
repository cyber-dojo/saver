FROM ghcr.io/cyber-dojo/sinatra-base:4d448af@sha256:d2d3fd0451afc5954ea4433e41f6f17ad6ad856bf607c9cd23dd4cf9c32b6ce8 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

# jq is not used by the saver server. It is installed for debugging scripts in
# sibling repos that docker-exec into a running saver container, such as
# web/bin/show_manifest.sh, which pretty-prints a kata's manifest.json.
#
# The workflow caches the bare image (this base stage) by a hash of this
# stage's instructions (comments and blank lines aside), so these unpinned
# packages are as new as the last change to those instructions. To pick up
# newer ones, eg a git security fix, bump APK_REFRESH.
ARG APK_REFRESH=1
RUN apk add git jq

# In-process git via libgit2 (the rugged gem) - see docs/in-process-git.md.
#
# rugged comes from cyber-dojo's fork, not from rubygems. The fork adds the
# :current_id compare-and-swap option to Rugged::ReferenceCollection#create,
# which External::Git#advance_main needs to move refs/heads/main only when it
# still points at the commit the change was built on. Upstream carries this as
# the open pull request https://github.com/libgit2/rugged/pull/1014; if that is
# merged and released, this goes back to `gem install rugged`. The fork's
# README.md explains the arrangement.
#
# The submodules are updated after the checkout, not cloned with --recursive,
# because rugged vendors libgit2 as a submodule at vendor/libgit2 and the
# gemspec packages source from it, so the submodule has to match the pinned
# commit. The pin keeps the image reproducible.
#
# rugged compiles that vendored libgit2 statically into its extension, so the
# build toolchain (and libgit2-dev) is only needed to compile it: install as a
# virtual package, build, then drop it. Re-add libgcc for the libgcc_s the
# compiled extension links at runtime (the only runtime lib not already provided
# by ruby; libssl/libcrypto/libz/libgmp are).
# rugged runs a bare gmake, so MAKEFLAGS=-j parallelises the libgit2 compile
# (~3x faster: 142s -> 43s on a 10-core builder).
ARG RUGGED_REPO=https://github.com/cyber-dojo/rugged.git
ARG RUGGED_SHA=e9f9caec0a485499d3420f7304a50a67d7779b2f
RUN apk add --no-cache --virtual .rugged-build-deps build-base cmake pkgconf libgit2-dev \
 && git clone "${RUGGED_REPO}" /tmp/rugged \
 && git -C /tmp/rugged checkout "${RUGGED_SHA}" \
 && git -C /tmp/rugged submodule update --init --recursive \
 && cd /tmp/rugged \
 && gem build rugged.gemspec \
 && MAKEFLAGS="-j$(nproc)" gem install ./rugged-*.gem \
 && cd / \
 && rm -rf /tmp/rugged \
 && apk del .rugged-build-deps \
 && apk add --no-cache libgcc

# path_coverage measures which paths through each decision and method the
# tests take, alongside SimpleCov's line and branch coverage. It is used only
# by the test suites (test/*/config/coverage.rb). It is pinned to keep the
# image reproducible.
RUN gem install --no-document path_coverage --version 0.7.2

ARG APP_DIR=/saver
ENV APP_DIR=${APP_DIR}

RUN adduser                        \
  -D               `# no password` \
  -G nogroup       `# no group`    \
  -H               `# no home dir` \
  -s /sbin/nologin `# no shell`    \
  -u 19663         `# user-id`     \
  saver            `# user-name`

# Created as root, before USER, so the saver user cannot add, remove or
# rename files in the source dir.
WORKDIR ${APP_DIR}/source
USER saver

# The stage above, base, is the bare image: Ruby, its gems, the OS packages
# and the saver user it runs as, with no source code. The stage below adds the source
# code, making the deployed image. Built with --target base it is the bare
# image the server tests run in (bin/run_tests_bare.sh); built with
# --build-context base=<that bare image>, the deployed image is built FROM
# the very bare image the tests ran in (.github/workflows/main.yml).
FROM base

ARG COMMIT_SHA
ENV COMMIT_SHA=${COMMIT_SHA}

# Owned by root, so the saver user it runs as cannot change its own code.
COPY --chown=root:root source/server/ .
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./config/up.sh" ]
