ARG BASE_IMAGE=always-provided
FROM ${BASE_IMAGE}
LABEL maintainer=jon@jaggersoft.com

RUN apk add git jq
RUN apk add --upgrade sqlite=3.45.3-r2   # https://security.snyk.io/vuln/SNYK-ALPINE320-SQLITE-9712342

# ARGs are reset after FROM See https://github.com/moby/moby/issues/34129
ARG BASE_IMAGE
ENV BASE_IMAGE=${BASE_IMAGE}

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
