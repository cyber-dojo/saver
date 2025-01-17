FROM cyberdojo/sinatra-base:d133c7f
LABEL maintainer=jon@jaggersoft.com

RUN apk add git jq

RUN adduser                        \
  -D               `# no password` \
  -G nogroup       `# no group`    \
  -H               `# no home dir` \
  -s /sbin/nologin `# no shell`    \
  -u 19663         `# user-id`     \
  saver            `# user-name`


RUN apk add git=2.45.3-r0
RUN apk upgrade

WORKDIR /saver
COPY source/server/ .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

USER saver
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /saver/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/saver/config/up.sh" ]
