FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

RUN adduser \
  -D         `# no password` \
  -H         `# no home dir` \
  -u 19663   `# user-id`     \
  -G nogroup `# group`       \
  saver      `# user-name`

COPY . /app
RUN chown -R saver /app

ARG SHA
ENV SHA=${SHA}

EXPOSE 4537
USER saver
CMD [ "./up.sh" ]
