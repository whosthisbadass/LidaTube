FROM python:3.12-alpine

ARG RELEASE_VERSION
ENV RELEASE_VERSION=${RELEASE_VERSION}

# Add redsocks, iptables, curl, etc.
RUN apk update && \
    apk add --no-cache ffmpeg su-exec redsocks iptables curl

COPY . /lidatube
WORKDIR /lidatube

ENV PYTHONPATH=/lidatube/src
RUN pip install --no-cache-dir -r requirements.txt

RUN chmod +x thewicklowwolf-init.sh
EXPOSE 5000

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
