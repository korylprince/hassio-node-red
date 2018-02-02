ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk add --no-cache jq nodejs

RUN apk add --no-cache py-rpigpio; exit 0

RUN mkdir /node-red && \
    cd /node-red && \
    npm install --no-optional --only=production node-red@0.18.0 bcryptjs && \
    npm cache clear --force && \
    mkdir /node-temp && \
    cd /node-temp && \
    npm install --no-optional --only=production node-red-contrib-home-assistant@0.2.1 && \
    cd / && \
    rm -Rf /node-temp

WORKDIR /data

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
