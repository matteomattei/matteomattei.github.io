---
title: Client and server SSL mutual authentication with NodeJs
description: Brief how-to on how to create an SSL mutual authenticated communication between client and server in Nodejs
author: Matteo Mattei
layout: post
permalink: /client-and-server-ssl-mutual-authentication-with-nodejs/
img_url:
categories:
  - security
  - nodejs
  - server
  - tcp
  - certificates
  - openssl
---

In order to communicate securely between server and client it is important not only to cipher the channel but also trust both endpoints. To do this, a common practice is to do mutual authentication between client and server.

In this post I show you how to implement mutual authentication in Nodejs.

Assume we want to create a mutual authentication channel between a server running on **server.aaa.com** and a client running on **client.bbb.com**.
Keep in mind the domain names because they are important in the certificates creation.

First of all we need to generate certificates. Obviously you can use certificates released by any certification authority but for the purpose of the article I am going to create self signed certificates and related CA.

## Step 1: Create a working folder and setup hosts file

```
// AS USER
$ mkdir ~/mutual_authentication_example
$ cd ~/mutual_authentication_example

// AS ROOT
# echo '127.0.0.1 server.aaa.com' >> /etc/hosts
# echo '127.0.0.1 client.bbb.com' >> /etc/hosts
```

## Step 2: Generate server certificates

We are going to create a Certification Authority (CA) certificate for the server with 1 year validity and the related key.

```
$ openssl req -new -x509 -days 365 -keyout server-ca-key.pem -out server-ca-crt.pem
Generating a RSA private key
...........................................................................................+++++
.......................................+++++
writing new private key to 'ca-key.pem'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:IT
State or Province Name (full name) [Some-State]:Florence
Locality Name (eg, city) []:Campi Bisenzio
Organization Name (eg, company) [Internet Widgits Pty Ltd]:AAA Ltd
Organizational Unit Name (eg, section) []:DevOps
Common Name (e.g. server FQDN or YOUR name) []:aaa.com
Email Address []:info@aaa.com
```

The PEM pass phrase is optional.
The other questions are not mandatory but it's better if you answer all.
The most important question is the **Common Name** which should be the server main domain (**aaa.com**).

Now we generate the actual server certificate which will be used in the ssl handshake.
First of all we have to generate a random key (4096 bit length in our example):

```
$ openssl genrsa -out server-key.pem 4096
Generating RSA private key, 4096 bit long modulus (2 primes)
.........++++
...................++++
e is 65537 (0x010001)
```

Then generate a Certificate Signing Request (CSR) with the key we have generated:

```
$ openssl req -new -sha256 -key server-key.pem -out server-csr.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:IT
State or Province Name (full name) [Some-State]:Florence
Locality Name (eg, city) []:Campi Bisenzio
Organization Name (eg, company) [Internet Widgits Pty Ltd]:AAA Ltd
Organizational Unit Name (eg, section) []:DevOps
Common Name (e.g. server FQDN or YOUR name) []:server.aaa.com
Email Address []:info@aaa.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Pay attention to the **Common Name** which must have the same name of the host will serve the application (**server.aaa.com**).
As final step, generate the server certificate (validity 1 year) from the CSR previously created and sign it with the CA key:

```
$ openssl x509 -req -days 365 -in server-csr.pem -CA server-ca-crt.pem -CAkey server-ca-key.pem -CAcreateserial -out server-crt.pem
Signature ok
subject=C = IT, ST = Florence, L = Campi Bisenzio, O = AAA Ltd, OU = DevOps, CN = server.aaa.com, emailAddress = info@aaa.com
Getting CA Private Key
Enter pass phrase for server-ca-key.pem:
```

The password requested is the one inserted during CA key generation.
To verify the certificate signature against the CA you can issue the following command:

```
$ openssl verify -CAfile server-ca-crt.pem server-crt.pem
server-crt.pem: OK
```

Now we have all the server certificates we need!

```
-rw-rw-r--  1 matteo matteo 1440 dic 26 12:52 server-ca-crt.pem
-rw-rw-r--  1 matteo matteo   41 dic 26 17:48 server-ca-crt.srl
-rw-------  1 matteo matteo 1854 dic 26 12:51 server-ca-key.pem
-rw-rw-r--  1 matteo matteo 1671 dic 26 17:48 server-crt.pem
-rw-rw-r--  1 matteo matteo 1785 dic 26 17:34 server-csr.pem
-rw-------  1 matteo matteo 3243 dic 26 17:30 server-key.pem
```

## Step 3: Generate client certificates

Now it's time to do the same steps for the Client.
First of all create a Certification Authority (CA) certificate for the client with 1 year validity and the related key.

```
$ openssl req -new -x509 -days 365 -keyout client-ca-key.pem -out client-ca-crt.pem
Generating a RSA private key
..........................................................+++++
.............................................+++++
writing new private key to 'client-ca-key.pem'
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
-----
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:IT
State or Province Name (full name) [Some-State]:Rome
Locality Name (eg, city) []:Rome
Organization Name (eg, company) [Internet Widgits Pty Ltd]:BBB Ltd
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:bbb.com
Email Address []:info@bbb.com
```

The PEM pass phrase is optional.
The other questions are not mandatory but it's better if you answer all.
The most important question is the **Common Name** which should be the client main domain (**bbb.com**).

Now we generate the actual client certificate which will be used in the ssl handshake.
First of all we have to generate a random key (4096 bit length in our example):

```
$ openssl genrsa -out client-key.pem 4096
Generating RSA private key, 4096 bit long modulus (2 primes)
..............++++
........................................................................................++++
e is 65537 (0x010001)
```

Then generate a Certificate Signing Request (CSR) with the key we have generated:

```
$ openssl req -new -sha256 -key client-key.pem -out client-csr.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:IT
State or Province Name (full name) [Some-State]:Rome
Locality Name (eg, city) []:Rome
Organization Name (eg, company) [Internet Widgits Pty Ltd]:BBB Ltd
Organizational Unit Name (eg, section) []:
Common Name (e.g. server FQDN or YOUR name) []:client.bbb.com
Email Address []:info@bbb.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```

Pay attention to the **Common Name** which must have the same name of the host will serve the application (**client.bbb.com**).
As final step, generate the client certificate (validity 1 year) from the CSR previously created and sign it with the CA key:

```
$ openssl x509 -req -days 365 -in client-csr.pem -CA client-ca-crt.pem -CAkey client-ca-key.pem -CAcreateserial -out client-crt.pem
Signature ok
subject=C = IT, ST = Rome, L = Rome, O = BBB Ltd, CN = client.bbb.com, emailAddress = info@bbb.com
Getting CA Private Key
Enter pass phrase for client-ca-key.pem:
```

The password requested is the one inserted during CA key generation.
To verify the certificate signature against the CA you can issue the following command:

```
$ openssl verify -CAfile client-ca-crt.pem client-crt.pem
client-crt.pem: OK
```

Now we have all the client certificates we need!

```
-rw-rw-r--  1 matteo matteo 1350 dic 26 17:59 client-ca-crt.pem
-rw-rw-r--  1 matteo matteo   41 dic 26 18:06 client-ca-crt.srl
-rw-------  1 matteo matteo 1854 dic 26 17:58 client-ca-key.pem
-rw-rw-r--  1 matteo matteo 1586 dic 26 18:06 client-crt.pem
-rw-rw-r--  1 matteo matteo 1712 dic 26 18:04 client-csr.pem
-rw-------  1 matteo matteo 3243 dic 26 18:03 client-key.pem
```

## Step 4: Run the code!

Move all certificates in a folder called **certs**:

```
$ mkdir ~/mutual_authentication_example/certs
$ mv ~/mutual_authentication_example/*.pem ~/mutual_authentication_example/certs/
$ mv ~/mutual_authentication_example/*.srl ~/mutual_authentication_example/certs/
```

Now create a **server.js** application:

```
const fs = require("fs");
const https = require("https");
const options = {
  key: fs.readFileSync(`${__dirname}/certs/server-key.pem`),
  cert: fs.readFileSync(`${__dirname}/certs/server-crt.pem`),
  ca: [
    fs.readFileSync(`${__dirname}/certs/client-ca-crt.pem`)
  ],
  // Requesting the client to provide a certificate, to authenticate.
  requestCert: true,
  // As specified as "true", so no unauthenticated traffic
  // will make it to the specified route specified
  rejectUnauthorized: true
};
https
  .createServer(options, function(req, res) {
    console.log(
      new Date() +
        " " +
        req.connection.remoteAddress +
        " " +
        req.method +
        " " +
        req.url
    );
    res.writeHead(200);
    res.end("OK!\n");
  })
  .listen(8888);
```

Now create a **client.js** application:

```
const fs = require("fs");
const https = require("https");
const message = { msg: "Hello!" };

const req = https.request(
  {
    host: "server.aaa.com",
    port: 8888,
    secureProtocol: "TLSv1_2_method",
    key: fs.readFileSync(`${__dirname}/certs/client-key.pem`),
    cert: fs.readFileSync(`${__dirname}/certs/client-crt.pem`),
    ca: [
      fs.readFileSync(`${__dirname}/certs/server-ca-crt.pem`)
    ],
    path: "/",
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      "Content-Length": Buffer.byteLength(JSON.stringify(message))
    }
  },
  function(response) {
    console.log("Response statusCode: ", response.statusCode);
    console.log("Response headers: ", response.headers);
    console.log(
      "Server Host Name: " + response.connection.getPeerCertificate().subject.CN
    );
    if (response.statusCode !== 200) {
      console.log(`Wrong status code`);
      return;
    }
    let rawData = "";
    response.on("data", function(data) {
      rawData += data;
    });
    response.on("end", function() {
      if (rawData.length > 0) {
        console.log(`Received message: ${rawData}`);
      }
      console.log(`TLS Connection closed!`);
      req.end();
      return;
    });
  }
);
req.on("socket", function(socket) {
  socket.on("secureConnect", function() {
    if (socket.authorized === false) {
      console.log(`SOCKET AUTH FAILED ${socket.authorizationError}`);
    }
    console.log("TLS Connection established successfully!");
  });
  socket.setTimeout(10000);
  socket.on("timeout", function() {
    console.log("TLS Socket Timeout!");
    req.end();
    return;
  });
});
req.on("error", function(err) {
  console.log(`TLS Socket ERROR (${err})`);
  req.end();
  return;
});
req.write(JSON.stringify(message));
```

It's now time to test. Open a terminal and start the server:

```
$ node server.js
```

Open another terminal and run the client:

```
$ node client.js
TLS Connection established successfully!
Response statusCode:  200
Response headers:  {
  date: 'Sat, 26 Dec 2020 17:26:13 GMT',
  connection: 'close',
  'transfer-encoding': 'chunked'
}
Server Host Name: server.aaa.com
Received message: OK!

TLS Connection closed!
```

On the first terminal (the server) will be logged a new connection:

```
$ node server.js
Sat Dec 26 2020 18:26:13 GMT+0100 (Central European Standard Time) ::ffff:127.0.0.1 GET /
```

## Conclusions

Basically you have to explicitly include the CA of the server in the connection object of the client and vice versa.
In this way the server will be able to verify the client certificate and the client will be able to verify the server certificate.

I hope this example can help you implementing a mutual authentication between your endpoints in your applications.
You can download demo files from this [GitHub repository](https://github.com/matteomattei/nodejs-ssl-mutual-authentication).
