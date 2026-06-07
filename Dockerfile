FROM ghcr.io/cyber-dojo/sinatra-base:6d1262a@sha256:2282f8f00e03aeaf93e6ae5753c57986b3e6458325e354139b6315b239e81791 AS base
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add git jq

# In-process git via libgit2 (the rugged gem) - see docs/in-process-git.md.
# rugged compiles a vendored libgit2 statically into its extension, so the build
# toolchain (and libgit2-dev) is only needed to compile it: install as a virtual
# package, build, then drop it. Re-add libgcc for the libgcc_s the compiled
# extension links at runtime (the only runtime lib not already provided by ruby;
# libssl/libcrypto/libz/libgmp are).
RUN apk add --no-cache --virtual .rugged-build-deps build-base cmake pkgconf libgit2-dev \
 && gem install rugged \
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
