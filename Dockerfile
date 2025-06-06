ARG VERSION_TAG=latest-ffmpeg
FROM bluenviron/mediamtx:${VERSION_TAG}
RUN apk add aws-cli
