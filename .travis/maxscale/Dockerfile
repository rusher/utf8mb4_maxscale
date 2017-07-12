FROM asosso/maxscale

RUN yum -y install MariaDB-client

COPY maxscale/docker-entrypoint.sh /
COPY maxscale/cmd.sh /usr/bin/

RUN chmod 777 /docker-entrypoint.sh
RUN chmod 777 /usr/bin/cmd.sh

EXPOSE 4006 4007

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/bin/cmd.sh"]