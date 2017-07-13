FROM centos:7

ARG MAXSCALE_VERSION
ENV MAXSCALE_VERSION ${MAXSCALE_VERSION:-v2.1.4}

COPY maxscale/mariadb.repo /etc/yum.repos.d/

RUN rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \
    && yum -y install https://downloads.mariadb.com/MaxScale/$MAXSCALE_VERSION/rhel/7/x86_64/maxscale-$MAXSCALE_VERSION-1.rhel.7.x86_64.rpm \
    && yum -y update

RUN yum -y install maxscale-$MAXSCALE_VERSION MariaDB-client \
    && yum clean all \
    && rm -rf /tmp/*

COPY maxscale/docker-entrypoint.sh /

RUN chmod 777 /docker-entrypoint.sh
RUN chmod 777 /etc/maxscale.cnf

EXPOSE 4006 4008

ENTRYPOINT ["/docker-entrypoint.sh"]