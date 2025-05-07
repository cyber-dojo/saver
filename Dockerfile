FROM cyberdojo/sinatra-base:0357618@sha256:3c4f92eb282f4dee797b37b703f6c4de0471eaebe94beec5ddb804cbade046be
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
