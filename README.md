# timestamping-server-with-digicert-freetsa
timestamping-server-with-digicert-freetsa


let's generate the proof that file.txt was signed at a precised timestamp by DIGICERT

generate a file.digicert.tsq file : a query, containing a SH512 of file to be sent to DIGICERT about the file.txt

```
openssl ts -query -data file.txt -no_nonce -sha512 -cert -out file.digicert.tsq

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
Status info:
Status: Granted.
Status description: unspecified
Failure info: unspecified

TST info:
Version: 1
Policy OID: 2.16.840.1.114412.7.1
Hash Algorithm: sha512
Message data:
    0000 - 0e 3e 75 23 4a bc 68 f4-37 8a 86 b3 f4 b3 2a 19   .>u#J.h.7.....*.
    0010 - 8b a3 01 84 5b 0c d6 e5-01 06 e8 74 34 57 00 cc   ....[......t4W..
    0020 - 66 63 a8 6c 1e a1 25 dc-5e 92 be 17 c9 8f 9a 0f   fc.l..%.^.......
    0030 - 85 ca 9d 5f 59 5d b2 01-2f 7c c3 57 19 45 c1 23   ..._Y]../|.W.E.#
Serial number: 0xE054E094488400DF537BCE57215FD45B
Time stamp: Mar  4 15:48:59 2023 GMT
Accuracy: unspecified
Ordering: no
Nonce: unspecified
TSA: unspecified
Extensions:
```

TIMESTAMP is  Time stamp: Mar  4 15:48:59 2023 GMT



Where you need it, you can verify that this response has been signed by DIGICERT for this file at this time

```
$ openssl ts -verify -in file.digicert.tsr -queryfile file.digicert.tsq -CAfile DigiCertAssuredIDRootCA.crt.pem -untrusted CHAIN.pem

Verification: OK
```

