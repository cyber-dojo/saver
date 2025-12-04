FROM ghcr.io/cyber-dojo/sinatra-base:28b632a@sha256:41f5d307193f8c917082ee23443cf4fdf0b17af249522e0495030a413c8b9bcd
LABEL maintainer=jon@jaggersoft.com

ARG COMMIT_SHA
ENV COMMIT_SHA=${COMMIT_SHA}

ARG APP_DIR
ENV APP_DIR=${APP_DIR}

WORKDIR /saver/source
COPY . .
USER nobody
HEALTHCHECK --interval=1s --timeout=1s --retries=5 --start-period=5s CMD ./config/healthcheck.sh
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD "${APP_DIR}/source/config/up.sh"
