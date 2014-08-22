---
title: How to cross compile CURL library with SSL and ZLIB support
description: Few simple instructions on how to cross-compile CURL library with SSL and ZLIB support for ARM
author: Matteo Mattei
layout: post
permalink: /how-to-cross-compile-curl-library-with-ssl-and-zlib-support/
img_url: https://farm4.staticflickr.com/3926/14973833856_5b0b328e8f_o.jpg
categories:
  - linux
  - embedded
  - curl
---
Every time I have to cross compile a new application or library it is always painful and I often have to spend several minutes (hours) to figure out how to build it. In this case I am going to show you how to cross compile [CURL](http://curl.haxx.se/) library (and application) with SSL and ZLIB support for an embedded system based on ARM.

First of all I suppose you already have all includes and libraries (static and dynamic) of openSSL and Zlib somewhere in your system (*how to cross-compile openssl and zlib is out of the scope of this post*).

In my case I have this structure:

```
.
├── openssl
│   ├── apps
│   │   └── openssl
│   ├── include
│   │   └── openssl
│   │       ├── aes.h
│   │       ├── asn1.h
│   │       ├── asn1_mac.h
│   │       ├── asn1t.h
│   │       ├── bio.h
│   │       ├── blowfish.h
│   │       ├── bn.h
│   │       ├── buffer.h
│   │       ├── camellia.h
│   │       ├── cast.h
│   │       ├── cmac.h
│   │       ├── cms.h
│   │       ├── comp.h
│   │       ├── conf_api.h
│   │       ├── conf.h
│   │       ├── crypto.h
│   │       ├── des.h
│   │       ├── des_old.h
│   │       ├── dh.h
│   │       ├── dsa.h
│   │       ├── dso.h
│   │       ├── dtls1.h
│   │       ├── ebcdic.h
│   │       ├── ecdh.h
│   │       ├── ecdsa.h
│   │       ├── ec.h
│   │       ├── engine.h
│   │       ├── e_os2.h
│   │       ├── err.h
│   │       ├── evp.h
│   │       ├── hmac.h
│   │       ├── idea.h
│   │       ├── krb5_asn.h
│   │       ├── kssl.h
│   │       ├── lhash.h
│   │       ├── md4.h
│   │       ├── md5.h
│   │       ├── mdc2.h
│   │       ├── modes.h
│   │       ├── objects.h
│   │       ├── obj_mac.h
│   │       ├── ocsp.h
│   │       ├── opensslconf.h
│   │       ├── opensslv.h
│   │       ├── ossl_typ.h
│   │       ├── pem2.h
│   │       ├── pem.h
│   │       ├── pkcs12.h
│   │       ├── pkcs7.h
│   │       ├── pqueue.h
│   │       ├── rand.h
│   │       ├── rc2.h
│   │       ├── rc4.h
│   │       ├── ripemd.h
│   │       ├── rsa.h
│   │       ├── safestack.h
│   │       ├── seed.h
│   │       ├── sha.h
│   │       ├── srp.h
│   │       ├── srtp.h
│   │       ├── ssl23.h
│   │       ├── ssl2.h
│   │       ├── ssl3.h
│   │       ├── ssl.h
│   │       ├── stack.h
│   │       ├── symhacks.h
│   │       ├── tls1.h
│   │       ├── ts.h
│   │       ├── txt_db.h
│   │       ├── ui_compat.h
│   │       ├── ui.h
│   │       ├── whrlpool.h
│   │       ├── x509.h
│   │       ├── x509v3.h
│   │       └── x509_vfy.h
│   └── libs
│       ├── lib4758cca.so
│       ├── libaep.so
│       ├── libatalla.so
│       ├── libcapi.so
│       ├── libchil.so
│       ├── libcrypto.a
│       ├── libcrypto.so
│       ├── libcrypto.so.1.0.0
│       ├── libcswift.so
│       ├── libgmp.so
│       ├── libgost.so
│       ├── libnuron.so
│       ├── libpadlock.so
│       ├── libssl.a
│       ├── libssl.so
│       ├── libssl.so.1.0.0
│       ├── libsureware.so
│       └── libubsec.so
└── zlib
    ├── include
    │   ├── zconf.h
    │   └── zlib.h
    └── libs
        ├── libz.a
        ├── libz.so -> libz.so.1.2.8
        ├── libz.so.1 -> libz.so.1.2.8
        └── libz.so.1.2.8
```

Now download the last version of CURL, decompress and configure it:

```
$ wget http://curl.haxx.se/download/curl-7.37.1.tar.gz
$ tar xzf curl-7.37.1.tar.gz
$ export ROOTDIR="${PWD}"
$ cd curl-7.37.1/
$ export CROSS_COMPILE="arm-none-linux-gnueabi"
$ export CPPFLAGS="-I${ROOTDIR}/openssl/include -I${ROOTDIR}/zlib/include"
$ export LDFLAGS="-L${ROOTDIR}/openssl/libs -L${ROOTDIR}/zlib/libs"
$ export AR=${CROSS_COMPILE}-ar
$ export AS=${CROSS_COMPILE}-as
$ export LD=${CROSS_COMPILE}-ld
$ export RANLIB=${CROSS_COMPILE}-ranlib
$ export CC=${CROSS_COMPILE}-gcc
$ export NM=${CROSS_COMPILE}-nm
$ export LIBS="-lssl -lcrypto"
$ ./configure --prefix=${ROOTDIR}/build --target=${CROSS_COMPILE} --host=${CROSS_COMPILE} --build=i586-pc-linux-gnu --with-ssl --with-zlib
```

At the end of the configure you should see a configuration resume similar to the following:

```
  curl version:     7.37.1
  Host setup:       arm-none-linux-gnueabi
  Install prefix:   /tmp/working_copy/build
  Compiler:         arm-none-linux-gnueabi-gcc
  SSL support:      enabled (OpenSSL)
  SSH support:      no      (--with-libssh2)
  zlib support:     enabled
  GSS-API support:  no      (--with-gssapi)
  SPNEGO support:   no      (--with-spnego)
  TLS-SRP support:  enabled
  resolver:         default (--enable-ares / --enable-threaded-resolver)
  ipv6 support:     no      (--enable-ipv6)
  IDN support:      no      (--with-{libidn,winidn})
  Build libcurl:    Shared=yes, Static=yes
  Built-in manual:  enabled
  --libcurl option: enabled (--disable-libcurl-option)
  Verbose errors:   enabled (--disable-verbose)
  SSPI support:     no      (--enable-sspi)
  ca cert bundle:   no
  ca cert path:     no
  LDAP support:     no      (--enable-ldap / --with-ldap-lib / --with-lber-lib)
  LDAPS support:    no      (--enable-ldaps)
  RTSP support:     enabled
  RTMP support:     no      (--with-librtmp)
  metalink support: no      (--with-libmetalink)
  HTTP2 support:    disabled (--with-nghttp2)
  Protocols:        DICT FILE FTP FTPS GOPHER HTTP HTTPS IMAP IMAPS POP3 POP3S RTSP SMTP SMTPS TELNET TFTP
```

Now compile and install it in the previously configured **build** directory:

```
$ make
$ make install
```

Now in the parent directory you should have a new folder called **build** with the new curl library and application with OpenSSL and Zlib support cross compiled for ARM:

```
build/
├── bin
│   ├── curl
│   └── curl-config
├── include
│   └── curl
│       ├── curlbuild.h
│       ├── curl.h
│       ├── curlrules.h
│       ├── curlver.h
│       ├── easy.h
│       ├── mprintf.h
│       ├── multi.h
│       ├── stdcheaders.h
│       └── typecheck-gcc.h
└── lib
    ├── libcurl.a
    ├── libcurl.la
    ├── libcurl.so -> libcurl.so.4.3.0
    ├── libcurl.so.4 -> libcurl.so.4.3.0
    ├── libcurl.so.4.3.0
    └── pkgconfig
        └── libcurl.pc
```

(I voluntary omitted the *share* folder in the tree exploded).

