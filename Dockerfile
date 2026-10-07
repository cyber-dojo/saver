FROM ghcr.io/cyber-dojo/sinatra-base:c58736f@sha256:35f8f0ad8bf53b955398392891ca64949787d414edb53789be8a628d76f6d217 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

# jq is not used by the saver server. It is installed for debugging scripts in
# sibling repos that docker-exec into a running saver container, such as
# web/bin/show_manifest.sh, which pretty-prints a kata's manifest.json.
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

ARG COMMIT_SHA
ENV COMMIT_SHA=${COMMIT_SHA}

ARG APP_DIR=/saver
ENV APP_DIR=${APP_DIR}

RUN adduser                        \
  -D               `# no password` \
  -G nogroup       `# no group`    \
  -H               `# no home dir` \
  -s /sbin/nologin `# no shell`    \
  -u 19663         `# user-id`     \
  saver            `# user-name`

WORKDIR ${APP_DIR}/source
COPY source/server/ .
USER saver
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "./config/up.sh" ]
