FROM cyberdojo/sinatra-base:0fcdde3
LABEL maintainer=jon@jaggersoft.com

WORKDIR /app
COPY --chown=nobody:nogroup . .

USER nobody
EXPOSE 4538

CMD [ "/app/config/up.sh" ]
