---
title: Subversion, webdav, LDAP and folder restrictions
description: A guide on how to configure subversion with webdav, LDAP users and folder restrictions under Linux
author: Matteo Mattei
layout: post
permalink: /subversion-webdav-ldap-and-folder-restrictions/
categories:
  - svn
  - ldap
  - server
  - ubuntu
---
If you need to configure a svn server on Linux with *LDAP authentication*, *webdav* and insert specific directory restrictions you can follow these instructions.

 1. You need to install subversion and apache in your Linux server (I will omit this part).
 2. You need to configure webdav to access svn over http and configure LDAP access.

    Make sure to have the following apache modules installed and configured:

    ```
    LoadModule authnz_ldap_module modules/mod_authnz_ldap.so
    LoadModule dav_module modules/mod_dav.so
    LoadModule dav_svn_module modules/mod_dav_svn.so
    LoadModule authz_svn_module modules/mod_authz_svn.so
    LoadModule authn_alias_module modules/mod_authn_alias.so
    ```

    Assumptions:

     - I am usual to configure subversion in **/srv/svn** folder.
     - The users allowed to access the SVN have to belong to the LDAP group **CN=SVN-AUTHORIZATION,OU=Groups GSO,DC=test,DC=example,DC=com**

    Edit */etc/apache2/mods-enabled/dav_svn.conf* (this is valid for Ubuntu. Maybe in other distributions this file is placed somewhere else) and make sure to have the following lines:

    ```
    <Location /svn/>
      # Enable svn over webdav
      DAV svn
      # Set parent path for multiple repositories
      SVNParentPath /srv/svn/
      # Set authentication type
      AuthType Basic
      # Set authentication name
      AuthName "FLR Subversion Repository"
      # Set authorization (permissions) file
      AuthzSVNAccessFile /etc/apache2/dav_svn.authz
      # Allow to list the parent path
      SVNListParentPath On
      # Use LDAP for authentication
      AuthBasicProvider ldap
      # LDAP server is authoritative (so is the final step for autentication)
      AuthzLDAPAuthoritative On
      # LDAP bind user
      AuthLDAPBindDN "CN=svnbind,OU=Users OS,DC=test,DC=example,DC=com"
      # LDAP bind password
      AuthLDAPBindPassword mypassword
      # LDAP URL
      AuthLDAPUrl "ldap://ldap_ip_address:389/DC=test,DC=example,DC=com?sAMAccountName?sub?(&(&(objectClass=user)(objectCategory=person))(memberof=CN=SVN-AUTHORIZATION,OU=Groups GSO,DC=test,DC=example,DC=com))"

      # A valid user is required
      Require valid-user
    </Location>
    ```
 3. Create the permission file */etc/apache2/dav_svn.authz*
    It will have the following content based on your needing:

    ```
    [groups]
    admin = matteo
    group1 = user1, user2, user3
    group2 = user2
    group3 = user4

    ###################################
    [/]
    * = r
    @admin = rw
    ###################################
    [repository1:/]
    * = rw
    ###################################
    [repository2:/]
    * =
    @admin = rw
    @group1 = rw
    ###################################
    [repository3:/]
    * =
    @admin = rw
    @group2 = rw
    @group1 = r
    ###################################
    [repository4:/]
    * = r
    @admin = rw
    [repository4:/trunk/sources]
    * = r
    @admin = rw
    @group3 = rw
    ###################################</pre>
    ```

    Now restart apache with

    ```
    /etc/init.d/apache2 restart
    ```
 4. Create repositories.
    As root issue the following commands:

    ```
    cd /srv/svn
    svnadmin create repository1
    chown www-data.www-data -R repository1
    svnadmin create repository2
    chown www-data.www-data -R repository2
    svnadmin create repository3
    chown www-data.www-data -R repository3
    svnadmin create repository4
    chown www-data.www-data -R repository4
    ```

You are now ready to use your new subversion repository with LDAP account, webdav access and custom user/group directory restrictions.
