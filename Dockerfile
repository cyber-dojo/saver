FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN adduser \
  -D       `# no password` \
  -H       `# no home dir` \
  -u 19663 `# user-id`     \
  saver    `# user-name`

ARG                   SAVER_HOME=/app
COPY .              ${SAVER_HOME}
RUN  chown -R saver ${SAVER_HOME}

ARG SHA
RUN echo ${SHA} > ${SAVER_HOME}/sha.txt

EXPOSE 4537
USER saver
CMD [ "./up.sh" ]
