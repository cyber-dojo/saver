FROM cyberdojo/sinatra-base:0fcdde3
LABEL maintainer=jon@jaggersoft.com

RUN adduser                        \
  -D               `# no password` \
  -G nogroup       `# no group`    \
  -H               `# no home dir` \
  -s /sbin/nologin `# no shell`    \
  -u 19663         `# user-id`     \
  saver            `# user-name`

WORKDIR /app
COPY . .
RUN chown -R saver .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

EXPOSE 4537
USER saver
CMD [ "./up.sh" ]
