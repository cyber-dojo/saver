FROM ghcr.io/cyber-dojo/sinatra-base:28b632a@sha256:41f5d307193f8c917082ee23443cf4fdf0b17af249522e0495030a413c8b9bcd
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add git jq
RUN apk add --upgrade sqlite=3.45.3-r2       # https://security.snyk.io/vuln/SNYK-ALPINE320-SQLITE-9712342
RUN apk add --upgrade sqlite-libs=3.45.3-r2  # https://security.snyk.io/vuln/SNYK-ALPINE320-SQLITE-9712342
RUN apk add --upgrade libexpat=2.7.2-r0      # https://security.snyk.io/vuln/SNYK-ALPINE320-EXPAT-13003709

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
