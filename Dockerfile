FROM ubuntu:trusty

RUN apt-get update && apt-get -y install wget curl && \
cd /etc/apt/sources.list.d && \
wget -qO - http://archive.cloudera.com/kudu/ubuntu/trusty/amd64/kudu/archive.key | sudo apt-key add - && \
wget http://archive.cloudera.com/kudu/ubuntu/trusty/amd64/kudu/cloudera.list && \
apt-get update && \
apt-get -y dist-upgrade && \
apt-get -y install kudu kudu-master kudu-tserver libkuduclient0 libkuduclient-dev

VOLUME /var/lib/kudu/master /var/lib/kudu/tserver

ENV KUDU_MASTER=boot2docker \
    USE_HYBRID_CLOCK=false \
    FLUSH_SECS=120

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 8050 8051 7050 7051
CMD ["help"]
