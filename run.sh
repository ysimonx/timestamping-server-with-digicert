# cf https://knowledge.digicert.com/generalinformation/INFO4231.html
# cf https://www.binalyze.com/blog/dfir-lab/protect-your-chain-of-custody-with-content-hashing-and-timestamping
# cf python https://github.com/pyauth/tsp-client qui indique que digicert n''est pas https ...'
echo "test" > file.txt
openssl ts -query -data file.txt -no_nonce -sha512 -cert -out file.digicert.tsq
curl -H "Content-Type: application/timestamp-query" --data-binary '@file.digicert.tsq'  http://timestamp.digicert.com > file.digicert.tsr



echo "timestamp token is"
openssl ts -reply -in file.digicert.tsr -text

sleep 10

echo 
echo "processing verification ..."
echo 
rm *.cer
wget https://knowledge.digicert.com/content/dam/digicertknowledgebase/attachments/time-stamp/TSACertificate.cer
wget https://knowledge.digicert.com/content/dam/digicertknowledgebase/DigiCertTrustedG4RSA4096SHA256TimeStampingCA.cer
wget https://knowledge.digicert.com/content/dam/digicertknowledgebase/DigiCertTrustedRootG4.cer

cat TSACertificate.cer > CHAIN.pem 
cat DigiCertTrustedG4RSA4096SHA256TimeStampingCA.cer >> CHAIN.pem
cat DigiCertTrustedRootG4.cer >> CHAIN.pem


openssl ts -verify -in file.digicert.tsr -queryfile file.digicert.tsq -CAfile DigiCertAssuredIDRootCA.crt.pem -untrusted CHAIN.pem