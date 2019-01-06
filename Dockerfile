FROM cyberdojo/rack-base
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

ARG SHA
ENV SHA=${SHA}

EXPOSE 4537
USER saver
CMD [ "./up.sh" ]
