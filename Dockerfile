FROM ghcr.io/cyber-dojo/sinatra-base:ba7acf3@sha256:8baa0ce05142cf89a9333bf0f5a1e6cfd9e2ce0c6b6e4464403410a3ab32c9f5
# The FROM statement above is typically set via an automated pull-request from the sinatra-base repo
LABEL maintainer=jon@jaggersoft.com

RUN apk add git jq

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
