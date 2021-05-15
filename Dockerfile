FROM cyberdojo/sinatra-base:e35b490
LABEL maintainer=jon@jaggersoft.com

RUN apk add git

RUN adduser                        \
  -D               `# no password` \
  -G nogroup       `# no group`    \
  -H               `# no home dir` \
  -s /sbin/nologin `# no shell`    \
  -u 19663         `# user-id`     \
  saver            `# user-name`

COPY . /
RUN chown -R saver:nogroup /app
# Note: The following does not (yet) work on circleci
# COPY --chown=saver:nogroup . /

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

USER saver
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /app/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/app/config/up.sh" ]
WORKDIR /app
