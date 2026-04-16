FROM ghcr.io/cyber-dojo/sinatra-base:a2408d5@sha256:d0d4d7f9c44500a5fae8275e777658ac9d2b09ea44e0313a4a56d698437da3e7
# FROM ghcr.io/cyber-dojo/sinatra-base:1b1df8e@sha256:0cf1c46e55c2c66cb7c55724f405784364be1d18cb7a2f47f6f0abf1cee0a80d
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add git jq

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
