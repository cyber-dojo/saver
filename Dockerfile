FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN adduser \
  -D       `# no password` \
  -H       `# no home dir` \
  -u 19663 `# user-id`     \
  saver    `# user-name`

ARG HOME=/app
ARG SHA
COPY . ${HOME}
RUN echo ${SHA} > ${HOME}/sha.txt
RUN chown -R saver ${HOME}

EXPOSE 4537
USER saver
CMD [ "./up.sh" ]
