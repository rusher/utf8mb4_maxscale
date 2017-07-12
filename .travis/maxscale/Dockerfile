FROM centos:7

RUN rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB \
    && yum -y install https://downloads.mariadb.com/enterprise/yzsw-dthq/generate/10.0/mariadb-enterprise-repository.rpm \
    && yum -y update \
    && yum -y install maxscale-$MAXSCALE_VERSION MariaDB-client\
    && yum clean all \
    && rm -rf /tmp/*

# We copy our config creator script to the container
COPY maxscale/docker-entrypoint.sh /
COPY maxscale/cmd.sh /usr/bin/

RUN chmod 777 /docker-entrypoint.sh
RUN chmod 777 /usr/bin/cmd.sh

# We expose our set Listener Ports
EXPOSE 4006 4007 4008 4442 6603

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/cmd.sh"]