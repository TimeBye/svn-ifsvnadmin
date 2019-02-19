FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse' >> /etc/apt/sources.list && \
    echo 'deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse' >> /etc/apt/sources.list

# Install apache2, php 5.6, subversion, IF.SVNAdmin
RUN apt update && \
    apt install --no-install-recommends -y software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt update && \
    apt install --no-install-recommends -y apache2 libapache2-mod-php5.6 php5.6-xml subversion-tools libapache2-mod-svn libapache2-svn curl unzip && \
    curl -L https://sourceforge.net/projects/ifsvnadmin/files/svnadmin-1.6.2.zip/download > svnadmin-1.6.2.zip && \
    unzip svnadmin-1.6.2.zip -d /var/www/html/ && rm -f svnadmin-1.6.2.zip && mv /var/www/html/iF.SVNAdmin-stable-1.6.2 /var/www/html/svnadmin && \
    apt remove -y python-software-properties software-properties-common curl unzip && \
    apt clean && apt autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /home/ubuntu/svndata && \
    mkdir /etc/apache2/conf && \
    touch /etc/apache2/conf/dav_svn.passwd && \
    touch /etc/apache2/conf/access_svn && \
    chown www-data /etc/apache2/conf/dav_svn.passwd && \
    chown www-data /etc/apache2/conf/access_svn && \
    a2dismod -f autoindex

# Manually set up the apache environment variables
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV SVN_LOCATION svnrepos

RUN echo '\n\
<location /${SVN_LOCATION}>\n\
    DAV svn\n\
    SVNPath /var/svn/repos\n\
    SVNListParentPath on\n\
    SVNReposName "Hisms SVN"\n\
    # authentication\n\
    AuthType Basic\n\
    AuthName "Subversion Server"\n\
    AuthBasicProvider ldap\n\
    AuthzSVNAccessfile /var/svn/repos/conf/authz\n\
    #AuthLDAPBindDN "CN=root,DC=xliu-home,DC=org"\n\
    #AuthLDAPBindPassword MyLdapPasswdInPlainText\n\
    AuthLDAPURL "ldap://ac.hand-china.com/ou=employee,dc=hand-china,dc=com?employeeNumber?sub?(objectClass=*)"\n\
    Require valid-user\n\
</location>\n'\
>> /etc/apache2/mods-enabled/dav_svn.conf

RUN chmod 777 /var/www/html/svnadmin/data

# Expose apache.
EXPOSE 80

CMD /usr/sbin/apache2ctl -D FOREGROUND