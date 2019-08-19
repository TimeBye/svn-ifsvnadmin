#!/bin/bash
AUTH_LDAP_URL="${AUTH_LDAP_URL:-ldap://ac.hand-china.com/ou=employee,dc=hand-china,dc=com?employeeNumber?sub?(objectClass=*)}"
cat > /etc/apache2/mods-available/dav_svn.conf << EOF
# dav_svn.conf - Example Subversion/Apache configuration
#
# For details and further options see the Apache user manual and
# the Subversion book.
#
# NOTE: for a setup with multiple vhosts, you will want to do this
# configuration in /etc/apache2/sites-available/*, not here.

# <Location URL> ... </Location>
# URL controls how the repository appears to the outside world.
# In this example clients access the repository as http://hostname/svn/
# Note, a literal /svn should NOT exist in your document root.
#<Location /svn>

  # Uncomment this to enable the repository
  #DAV svn

  # Set this to the path to your repository
  #SVNPath /var/lib/svn
  # Alternatively, use SVNParentPath if you have multiple repositories under
  # under a single directory (/var/lib/svn/repo1, /var/lib/svn/repo2, ...).
  # You need either SVNPath and SVNParentPath, but not both.
  #SVNParentPath /var/lib/svn

  # Access control is done at 3 levels: (1) Apache authentication, via
  # any of several methods.  A "Basic Auth" section is commented out
  # below.  (2) Apache <Limit> and <LimitExcept>, also commented out
  # below.  (3) mod_authz_svn is a svn-specific authorization module
  # which offers fine-grained read/write access control for paths
  # within a repository.  (The first two layers are coarse-grained; you
  # can only enable/disable access to an entire repository.)  Note that
  # mod_authz_svn is noticeably slower than the other two layers, so if
  # you don't need the fine-grained control, don't configure it.

  # Basic Authentication is repository-wide.  It is not secure unless
  # you are using https.  See the 'htpasswd' command to create and
  # manage the password file - and the documentation for the
  # 'auth_basic' and 'authn_file' modules, which you will need for this
  # (enable them with 'a2enmod').
  #AuthType Basic
  #AuthName "Subversion Repository"
  #AuthUserFile /etc/apache2/dav_svn.passwd

  # To enable authorization via mod_authz_svn (enable that module separately):
  #<IfModule mod_authz_svn.c>
  #AuthzSVNAccessFile /etc/apache2/dav_svn.authz
  #</IfModule>

  # The following three lines allow anonymous read, but make
  # committers authenticate themselves.  It requires the 'authz_user'
  # module (enable it with 'a2enmod').
  #<LimitExcept GET PROPFIND OPTIONS REPORT>
    #Require valid-user
  #</LimitExcept>

#</Location>
<Location /svn>
    DAV svn
    SVNParentPath /var/www/html/svnrepos
    SVNListParentPath on
    SVNReposName "Choerodon SVN"
    # authentication
    AuthType Basic
    AuthName "Subversion Server"
    AuthBasicProvider ldap
    # 授权文件
    AuthzSVNAccessfile /var/www/html/svnrepos/authorization
    #AuthLDAPBindDN "CN=root,DC=xliu-home,DC=org"
    #AuthLDAPBindPassword MyLdapPasswdInPlainText
    AuthLDAPURL "${AUTH_LDAP_URL}"
    Require valid-user
</Location>
EOF

if [ ! -e "/var/www/html/svnadmin/data/config.ini" ];then
    mkdir -p /var/www/html/svnadmin/data
    cp -rf /var/www/html/svnadmin/data.bak/* /var/www/html/svnadmin/data
fi

touch /var/www/html/svnrepos/authorization
chown www-data:www-data -R /var/www/html/svnadmin/data /var/www/html/svnrepos /var/www/html/svnrepos/authorization
/usr/sbin/apache2ctl -D FOREGROUND
wait