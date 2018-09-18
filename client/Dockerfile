FROM  cyberdojo/rack-base
LABEL maintainer=jon@jaggersoft.com

ARG                            GROUPER_HOME=/app
COPY .                       ${GROUPER_HOME}
RUN  chown -R nobody:nogroup ${GROUPER_HOME}
USER nobody
EXPOSE 4538
CMD [ "./up.sh" ]
