FROM cyberdojo/sinatra-base:a903598@sha256:12f9997694fbc19acbdc2ac4c3e616ff5896c4e8e7bc5d37a961af2245e5e18d
LABEL maintainer=jon@jaggersoft.com

WORKDIR /saver
COPY . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /saver/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/saver/config/up.sh" ]
