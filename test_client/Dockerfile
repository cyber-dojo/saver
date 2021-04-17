FROM cyberdojo/sinatra-base:0fcdde3
LABEL maintainer=jon@jaggersoft.com

COPY . /app
RUN chown -R nobody:nogroup /app
USER nobody
EXPOSE 4538
CMD [ "./up.sh" ]
