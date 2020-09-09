openssl req -x509 -nodes -days 365 \
  -subj "/C=CA/ST=QC/O=Company, Inc./CN=mydomain.com" \
  -addext "subjectAltName=DNS:mydomain.com" \
  -newkey rsa:2048 \
  -keyout dev.key \
  -out dev.crt;
