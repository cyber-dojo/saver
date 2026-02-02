FROM ghcr.io/cyber-dojo/sinatra-base:dd38f41@sha256:78e366649c6b28379a7666503149d71aa154960b9421e8a57721da13c1eb7ab1
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add --upgrade openssl=3.5.5-r0 # https://security.snyk.io/vuln/SNYK-ALPINE322-OPENSSL-15121113
RUN apk add --upgrade c-ares=1.34.6-r0 # https://security.snyk.io/vuln/SNYK-ALPINE322-CARES-14409293
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
