# timestamping-server-with-digicert-freetsa


Based upon https://knowledge.digicert.com/generalinformation/INFO4231.html

Let's generate the proof that file.txt was signed at a precised timestamp by DIGICERT

generate a file.digicert.tsq file : a query, containing a SH256 of file to be sent to DIGICERT about the file.txt

```
openssl ts -query -data file.txt -no_nonce -SH256 -cert -out file.digicert.tsq

```

send this request to DIGICERT and retrieve the signed response
```
curl -H "Content-Type: application/timestamp-query" --data-binary '@file.digicert.tsq'  http://timestamp.digicert.com > file.digicert.tsr
```

file.digicert.tsr is the signed reponse sent by DIGICERT, 

it is possible to take a look at it

```
$ openssl ts -reply -in file.digicert.tsr -text

timestamp token is
Using configuration from /opt/homebrew/etc/openssl@3/openssl.cnf
Status info:
Status: Granted.
Status description: unspecified
Failure info: unspecified

TST info:
Version: 1
Policy OID: 2.16.840.1.114412.7.1
Hash Algorithm: sha256
Message data:
    0000 - f2 ca 1b b6 c7 e9 07 d0-6d af e4 68 7e 57 9f ce   ........m..h~W..
    0010 - 76 b3 7e 4e 93 b7 60 50-22 da 52 e6 cc c2 6f d2   v.~N..`P".R...o.
Serial number: 0x40D1BF800F708CEC9F6828C2C856AD8F
Time stamp: May  5 07:51:50 2025 GMT
Accuracy: unspecified
Ordering: no
Nonce: unspecified
TSA: unspecified
Extensions:

```

TIMESTAMP is  Time stamp: May  5 07:51:50 2025 GMT



Where you need it, you can verify that this response has been signed by DIGICERT for this file at this time

note that 2 certificates from Digicert must be used ... See run.sh for more informations

```
$ openssl ts -verify -in file.digicert.tsr -queryfile file.digicert.tsq -CAfile DigiCertAssuredIDRootCA.crt.pem -untrusted CHAIN.pem

Verification: OK
```

