FROM centos:7 as builder
ENV KUDU_URL=https://archive.apache.org/dist/kudu/1.6.0/apache-kudu-1.6.0.tar.gz
RUN yum -y update && \
  yum -y install wget curl autoconf automake cyrus-sasl-devel cyrus-sasl-gssapi \
  cyrus-sasl-plain flex gcc gcc-c++ gdb git java-1.8.0-openjdk-devel \
  krb5-server krb5-workstation libtool make openssl-devel patch \
  pkgconfig redhat-lsb-core rsync unzip vim-common which && \
  wget -qO /tmp/kudu.tar.gz $KUDU_URL && \
  mkdir -p /tmp/kudu && \
  tar xzf /tmp/kudu.tar.gz -C /tmp/kudu --strip-components=1
WORKDIR /tmp/kudu
RUN build-support/enable_devtoolset.sh thirdparty/build-if-necessary.sh && mkdir -p build/release
WORKDIR /tmp/kudu/build/release
RUN ../../build-support/enable_devtoolset.sh \
  ../../thirdparty/installed/common/bin/cmake \
  -DCMAKE_BUILD_TYPE=release \
  ../.. && \
  make -j4 && \
  make DESTDIR=/opt/kudu install && \
  mkdir /opt/kudu/bin && \
  mv /tmp/kudu/build/release/bin/kudu /opt/kudu/bin/ && \
  mv /tmp/kudu/build/release/bin/kudu-tserver /opt/kudu/bin/ && \
  mv /tmp/kudu/build/release/bin/kudu-master /opt/kudu/bin/
WORKDIR /opt/kudu
RUN rm -rf /tmp/kudu /tmp/kudu.tar.gz

FROM centos:7 as kudu-runner
RUN yum install -y cyrus-sasl-plain
COPY --from=builder /opt/kudu /
WORKDIR /opt/kudu
VOLUME /var/lib/kudu/master /var/lib/kudu/tserver
ENV KUDU_MASTER=boot2docker \
    USE_HYBRID_CLOCK=false \
    FLUSH_SECS=120
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
EXPOSE 8050 8051 7050 7051
CMD ["help"]
