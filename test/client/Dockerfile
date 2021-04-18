FROM cyberdojo/sinatra-base:0fcdde3
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY . .
RUN chown -R nobody:nogroup /app
# Note: The following does not (yet) work on circleci
# COPY --chown=nobody:nogroup . /app

USER nobody
EXPOSE 4538

ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/app/config/up.sh" ]
