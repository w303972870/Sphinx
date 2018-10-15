FROM centos:latest

MAINTAINER Eric Wang

ADD Dockerfile /root/
ADD docker-entrypoint.sh /usr/local/bin/

RUN yum -y install make gcc g++ gcc-c++ libtool autoconf automake imake mysql-devel libxml2-devel expat-devel wget \
    && wget http://sphinxsearch.com/files/sphinx-3.0.3-facc3fb-linux-amd64.tar.gz -O /root/sphinx-3.0.3-facc3fb-linux-amd64.tar.gz \
    && cd /root/ && tar zxf sphinx-3.0.3-facc3fb-linux-amd64.tar.gz && cd sphinx-3.0.3 \
    && mkdir -p /usr/local/sphinx && cd api/libsphinxclient && ./configure --prefix=/usr/local/sphinx \
    && make && make install && cp -R /root/sphinx-3.0.3/* /usr/local/sphinx/ && chmod -R +x /usr/local/sphinx/bin/* \
    && rm -rf /root/sphinx* && yum install -y epel-release && yum clean all && yum -y update && yum clean all \
    && yum -y install supervisor cronie yum-cron && yum clean all && mkdir -p /data/supervisor/logs/ /data/supervisor/etc/ \
    && mkdir -p /data/sphinx/logs/ /data/sphinx/etc/ /data/sphinx/data/ && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && yum clean all && mkdir -p /data/crontab/ && rm -rf /etc/cron.d && ln -s /data/crontab/ /etc/cron.d

ADD supervisord.conf /data/supervisor/etc/
ADD sphinx.conf /data/sphinx/etc/

EXPOSE 9002 9312 9306


ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["supervisord", "-n", "-c","/data/supervisor/etc/supervisord.conf"]
