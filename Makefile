SHELL=/bin/bash

up:
	docker-compose up -d

down:
	docker-compose down

fake-creds:
	mkdir -p .chainlink-ropsten
	echo S0mef4ke455p455 > .chainlink-ropsten/.password
	echo hackathon@chain.link > .chainlink-ropsten/.api
	echo S0mef4ke455p455 >> .chainlink-ropsten/.api

root-cert:
	mkdir -p certs
	openssl genrsa -des3 -out certs/chainlink-orbitdb.key 2048
	openssl req -x509 \
		-new -nodes \
		-key certs/chainlink-orbitdb.key \
		-sha256 \
		-days 1024 \
		-out certs/chainlink-orbitdb.pem
	mkdir -p /usr/local/share/ca-certificates/extra
	cp certs/chainlink-orbitdb.pem /usr/local/share/ca-certificates/extra/chainlink-orbitdb.crt
	update-ca-certificates

uninstall-root-cert:
	rm -rf /usr/local/share/ca-certificates/extra/chainlink-orbitdb.crt
	rmdir --ignore-fail-on-non-empty /usr/local/share/ca-certificates/extra
	update-ca-certificates

keygen:
	openssl req \
		-new -sha256 -nodes \
		-out certs/localhost.csr \
		-newkey rsa:2048 -keyout certs/localhost.key \
		-subj "/C=AU/ST=WA/L=City/O=Organization/OU=OrganizationUnit/CN=localhost/emailAddress=demo@example.com"
	openssl x509 \
		-req \
		-in certs/localhost.csr \
		-CA certs/chainlink-orbitdb.pem -CAkey certs/chainlink-orbitdb.key -CAcreateserial \
		-out certs/localhost.crt \
		-days 500 \
		-sha256 \
		-extfile <(echo " \
			[ v3_ca ]\n \
			authorityKeyIdentifier=keyid,issuer\n \
			basicConstraints=CA:FALSE\n \
			keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n \
			subjectAltName=DNS:localhost \
			")
