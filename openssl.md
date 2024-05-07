# Openssl

```bash
# check details of certificate 
$ openssl s_client -connect host:port

# more verbose
$ openssl s_client -connect host:port -debug

# check cert
$ openssl x509 -in certificate.crt -text -noout

# check private key
$ openssl rsa -in privateKey.key -check
```
