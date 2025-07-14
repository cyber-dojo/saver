FROM cyberdojo/sinatra-base:d58b8c5@sha256:d5d5e239fd9cef0a192bfdc23d56d2eccd24159fc65f84147dbcf75e2002e11a
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add git jq
RUN apk add --upgrade sqlite=3.45.3-r2       # https://security.snyk.io/vuln/SNYK-ALPINE320-SQLITE-9712342
RUN apk add --upgrade sqlite-libs=3.45.3-r2  # https://security.snyk.io/vuln/SNYK-ALPINE320-SQLITE-9712342

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

RUN adduser                        \
  -D               `# no password` \
  -G nogroup       `# no group`    \
  -H               `# no home dir` \
  -s /sbin/nologin `# no shell`    \
  -u 19663         `# user-id`     \
  saver            `# user-name`

WORKDIR /saver
COPY source/server/ .
USER saver
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /saver/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/saver/config/up.sh" ]
