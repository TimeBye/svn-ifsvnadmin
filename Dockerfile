FROM ubuntu:16.04
ENV APACHE_LOG_DIR=/var/log/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_PID_FILE=/var/run/apache2.pid

COPY docker-entrypoint.sh config.tpl.ini /

RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak && \
    sed -i 's archive.ubuntu.com mirrors.aliyun.com g;s security.ubuntu.com mirrors.aliyun.com g' /etc/apt/sources.list

# Install apache2, php 5.6, subversion, IF.SVNAdmin
RUN apt update && \
    apt install --no-install-recommends -y software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt update && \
    apt install --no-install-recommends -y \
        vim \
        curl \
        wget \
        unzip  \
        apache2 \
        libapache2-mod-php5.6\
        php5.6-xml \
        php5.6-ldap \
        subversion-tools \
        libapache2-mod-svn \
        libapache2-svn && \
    wget -O svnadmin-1.6.2.zip https://sourceforge.net/projects/ifsvnadmin/files/svnadmin-1.6.2.zip/download && \
    unzip svnadmin-1.6.2.zip -d /var/www/html/ && \
    rm -f svnadmin-1.6.2.zip && \
    mv /var/www/html/iF.SVNAdmin-stable-1.6.2 /var/www/html/svnadmin && \
    mv /var/www/html/svnadmin/data /var/www/html/svnadmin/data.bak && \
    mv /config.tpl.ini /var/www/html/svnadmin/data.bak && \
    apt clean && apt autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/www/html/svnrepos && \
    a2dismod -f autoindex && \
    a2enmod ldap authnz_ldap

# Expose apache.
EXPOSE 80
CMD [ "/docker-entrypoint.sh" ]