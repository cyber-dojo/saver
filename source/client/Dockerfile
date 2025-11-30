FROM ghcr.io/cyber-dojo/sinatra-base:28b632a@sha256:41f5d307193f8c917082ee23443cf4fdf0b17af249522e0495030a413c8b9bcd
LABEL maintainer=jon@jaggersoft.com

WORKDIR /saver
COPY . .

ARG COMMIT_SHA
ENV SHA=${COMMIT_SHA}

USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD /saver/config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD [ "/saver/config/up.sh" ]
