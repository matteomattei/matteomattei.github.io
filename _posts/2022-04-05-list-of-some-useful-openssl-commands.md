---
title: List of some useful openssl commands
description: This is a list of some useful openssl commands you can use in your work days
author: Matteo Mattei
layout: post
permalink: /list-of-some-useful-openssl-commands/
img_url:
categories:
  - security
  - openssl
  - ssl
  - encryption
  - certificates
---

This is a list of some useful openssl commands I used. Just a brief description of what you need to to and the actual command, no more!


- Verify if a certificate belongs to a CA:

```
openssl verify -CAfile ca.pem certificate.pem
```

- Verify if a certificate and a key matches (hashes must be equal):

```
openssl x509 -noout -modulus -in certificate.pem | openssl md5
openssl rsa -noout -modulus -in key.pem | openssl md5
```

- Print certificate information

```
openssl x509 -in certificate.pem -noout -text
```

- Generate key and certificate (CA)

```
openssl req -new -x509 -days 365 -keyout ca-key.pem -out ca-cert.pem
```

- Generate a randomic private key of 4096 bits

```
openssl genrsa -out privkey.pem 4096
```

- Generate a CSR (certificate signing request):

```
openssl req -new -sha256 -key privkey.pem -out csr.pem
```

- Generate a certificate starting from CSR and sign it with the CA:

```
openssl x509 -req -days 365 -in csr.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out certificate.pem
```

- Convert pkcs7 certificate to pem:

```
openssl pkcs7 -inform der -in certificate.p7c -print_certs -out certificate.pem
```
