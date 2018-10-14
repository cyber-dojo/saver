FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

# - - - - - - - - - - - - - - - - - -
# copy source & set ownership
# - - - - - - - - - - - - - - - - - -

RUN adduser \
  -D       `# no password` \
  -H       `# no home dir` \
  -u 19663 `# user-id`     \
  saver    `# user-name`

ARG                   SAVER_HOME=/app
COPY .              ${SAVER_HOME}
RUN  chown -R saver ${SAVER_HOME}

# - - - - - - - - - - - - - - - - -
# git commit sha image is built from
# - - - - - - - - - - - - - - - - -

ARG SHA
RUN echo ${SHA} > ${SAVER_HOME}/sha.txt

# - - - - - - - - - - - - - - - - - -
# bring it up
# - - - - - - - - - - - - - - - - - -

USER saver
EXPOSE 4537
CMD [ "./up.sh" ]

