# cf https://knowledge.digicert.com/generalinformation/INFO4231.html
# cf https://www.openssl.org/docs/man1.1.1/man1/openssl-ts.html
# cf https://www.binalyze.com/blog/dfir-lab/protect-your-chain-of-custody-with-content-hashing-and-timestamping
# cf python https://github.com/pyauth/tsp-client qui indique que digicert n''est pas https ...'
echo "test" > file.txt

# in one line : file.txt -> sha512 -> build query -> file.digicert.tsq
openssl ts -query -data file.txt -no_nonce -sha512 -cert -out file.digicert.tsq

echo "request query is : "
openssl ts -query -in file.digicert.tsq -text
sleep 5


curl -H "Content-Type: application/timestamp-query" --data-binary '@file.digicert.tsq'  http://timestamp.digicert.com > file.digicert.tsr
echo "timestamp token is"
openssl ts -reply -in file.digicert.tsr -text

sleep 10

echo 
echo "processing verification ..."
echo 
sleep

echo "downloading digicert's public certificates"
rm *.cer
rm DigiCertAssuredIDRootCA.crt.pem
wget https://cacerts.digicert.com/DigiCertAssuredIDRootCA.crt.pem

echo
echo
echo "verifying previous response with digicert's public certificate DigiCertAssuredIDRootCA.crt.pem"
sleep 5
echo


openssl ts -verify -in file.digicert.tsr -queryfile file.digicert.tsq -CAfile DigiCertAssuredIDRootCA.crt.pem