FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN adduser \
  -D       `# no password` \
  -H       `# no home dir` \
  -u 19663 `# user-id`     \
  saver    `# user-name`

COPY . /app
RUN chown -R saver /app

EXPOSE 4537
USER saver
CMD [ "./up.sh" ]
