FROM ubuntu:16.04
ENV DEBIAN_FRONTEND="noninteractive"

RUN sed -i 's/archive.ubuntu/ir.archive.ubuntu/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get install software-properties-common vim git supervisor  -y
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
RUN LC_ALL=C.UTF-8 add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.osuosl.org/pub/mariadb/repo/10.1/ubuntu xenial main' -y
RUN apt-get update
RUN apt install mariadb-server php mcrypt php7.0-mcrypt pdns-server pdns-backend-mysql php7.0-mysql nginx -y
RUN git clone https://github.com/poweradmin/poweradmin.git /var/www/html/pdns

COPY dump.pdns.sql /dump.pdns.sql
RUN /etc/init.d/mysql restart && mysql < /dump.pdns.sql
#COPY run.sh /run.sh
#RUN chmod +x /run.sh
RUN rm /etc/powerdns/pdns.d/*
COPY pdns.local.gmysql.conf /etc/powerdns/pdns.d/pdns.local.gmysql.conf
COPY config.inc.php /var/www/html/pdns/inc/config.inc.php 
COPY nginx.pdns  /etc/nginx/sites-available/pdns
RUN rm -rf /etc/nginx/sites-enabled/*
RUN ln -sf /etc/nginx/sites-available/pdns /etc/nginx/sites-enabled/
RUN rm -rf /var/www/html/pdns/install

ADD supervisor.conf /etc/supervisor/conf.d/milux_supervisord.conf
RUN sed -i 's/^\(\[supervisord\]\)$/\1\nnodaemon=true/' /etc/supervisor/supervisord.conf
ADD start-supervisor.sh /opt/start-supervisor.sh
RUN chmod +x /opt/start-supervisor.sh

EXPOSE 80
EXPOSE 53
EXPOSE 53/udp
ENTRYPOINT ["/opt/start-supervisor.sh"]
