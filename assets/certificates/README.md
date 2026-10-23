# GoGetSSL RSA DV CA

`gogetssl_rsa_dv_ca.pem` contains the complete public intermediate certificate,
without a private key. It fills the missing intermediate in the TLS chain served
by `consumer.oofd.kz`, as observed on 2026-10-07. See
[the verification record](../../docs/OFD_TLS.md).

Official sources:

- [GoGetSSL certificate catalog, legacy Sectigo DV RSA section](https://www.gogetssl.com/wiki/intermediate-certificates/gogetssl-intermediate-root-certificates/)
- [GoGetSSL HTTPS certificate download](https://gogetssl-cdn.s3.eu-central-1.amazonaws.com/wiki/gogetssl-rsa-dv-ca.txt)
- [Issuer AIA download](http://crt.usertrust.com/GoGetSSLRSADVCA.crt)

The two sources contain identical DER certificates. DER SHA-256:
`43cac31ef8e8ba1b4b16b8206e4c0a26c5badb2fc3aa09e90170e41b66c2fd64`.

The certificate is owned by Sectigo. [Sectigo CPS 5.3.6, section 9.17.3,
page 116](https://www.sectigo.com/uploads/files/Sectigo_CPS_v5_3_6.pdf)
permits nonexclusive, royalty-free reproduction and distribution of complete
certificates. This file preserves the full certificate; only its DER-to-PEM
encoding was changed. It is not licensed as application source code.
