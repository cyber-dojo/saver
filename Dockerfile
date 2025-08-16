FROM ghcr.io/cyber-dojo/sinatra-base:c7abc15@sha256:dd692d91c186a4ca225ae2b778d251cdd8d52d0e8cb035668d7b5fa906a10ee4
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
