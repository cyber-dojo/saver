FROM ghcr.io/cyber-dojo/sinatra-base:b757853@sha256:e08a1a8f707ddb56f2c84b1f7eaaa5ca33e5d64bc1e53f2fd7412fa264b3ac0c
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
