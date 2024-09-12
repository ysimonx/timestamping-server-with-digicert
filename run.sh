# cf https://knowledge.digicert.com/generalinformation/INFO4231.html
# cf https://www.openssl.org/docs/man1.1.1/man1/openssl-ts.html
# cf https://www.binalyze.com/blog/dfir-lab/protect-your-chain-of-custody-with-content-hashing-and-timestamping
# cf python https://github.com/pyauth/tsp-client qui indique que digicert n''est pas https ...'

# echo "test" > file.txt

# in one line : file.txt -> sha512 -> build query -> file.digicert.tsq
#
# note yannick  : le -sha256 fabrique la meme chaine que  'shasum -a 256 file.txt' et l'inclue
# dans le fichier tsq. (cf regarder en hexa)

# file.digicert.tsq donne en hexa : 
# 00000000	30 39 02 01 01 30 31 30	0d 06 09 60 86 48 01 65		09...010...`.H.e
# 00000010	03 04 02 01 05 00 04 20	80 6e 97 fb e8 09 00 d7		....... .n......
# 00000020	64 b3 ee 4e 7a 54 1f a4	31 36 46 6d e1 b4 fb ef		d..NzT.16Fm....
# 00000030	ae 75 94 48 91 9b b0 e9	01 01 ff		            .u.H.......

# 
# et shasum -a 256 file.txt donne en hexa
# 806e97fbe80900d764b3ee4e7a541fa43136466de1b4fbefae759448919bb0e9
#

# 30 31 30 0d 06 09 60 86 48 01 65 03 04 02 01

# le "30 31 30 0d 06 09 60 86 48 01 65 03 04 02 01 05 00" 
# indique que c'est du sha256 
# (cf https://github.com/pyauth/tsp-client/blob/main/tsp_client/algorithms.py)
# et
# (cf https://gist.github.com/hnvn/38ef37566471f1135773b5426fb73011 tout en bas pour expliquer le 05 00)

# le plus basique
openssl ts -query -data file.txt -no_nonce -sha256 -out file.digicert.tsq

# avec Policy OID: tsa_policy1
# ex:
# tsa_policy1             = 1.2.3.4.1
# tsa_policy2             = 1.2.3.4.5.6

openssl ts -query -data file.txt -no_nonce -sha256 --tspolicy 1.2.3.4.1 -out file.digicert.withpolicyid.tsq


# avec Policy OID: tsa_policy1
# avec nonce

openssl ts -query -data file.txt -sha256 --tspolicy 1.2.3.4.1 -out file.digicert.withpolicyid.withnonce.tsq


# sans Policy OID
# avec nonce

openssl ts -query -data file.txt -sha256 -out file.digicert.withoutpolicyid.withnonce.tsq


echo "request query is : "
openssl ts -query -in file.digicert.tsq -text
sleep 5


curl -H 'Content-Type: application/timestamp-query' --data-binary '@file.digicert.tsq'  http://timestamp.digicert.com > file.digicert.tsr
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
echo "verifying previous response with digicert's public certificates"
sleep 5
echo

# verification avec le fichier initial "file.txt"
openssl ts -verify -data file.txt -in file.digicert.tsr -CAfile DigiCertAssuredIDRootCA.crt.pem


# verification avec le fichier de query        
openssl ts -verify -in file.digicert.tsr -queryfile file.digicert.tsq -CAfile DigiCertAssuredIDRootCA.crt.pem

# verification avec le sha256 du fichier  
shasum -a 256 file.txt => 806e97fbe80900d764b3ee4e7a541fa43136466de1b4fbefae759448919bb0e9
openssl ts -verify -digest 806e97fbe80900d764b3ee4e7a541fa43136466de1b4fbefae759448919bb0e9 -in file.digicert.tsr -CAfile DigiCertAssuredIDRootCA.crt.pem
