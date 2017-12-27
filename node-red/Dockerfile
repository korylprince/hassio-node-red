ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk add --no-cache jq nodejs

RUN npm install --global --no-optional --only=production node-red node-red-contrib-home-assistant bcryptjs && \
    npm cache clear --force

WORKDIR /data

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
