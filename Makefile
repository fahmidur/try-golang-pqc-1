default:
	@echo 'no default'

certs:
	mkdir ./certs/
	openssl req -x509 -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout ./certs/pqc.key \
  -out ./certs/pqc.crt \
  -subj "/C=US/ST=California/L=Los Angeles/O=Example/OU=IT/CN=echo-pqc-1.lvh.me"

develop: certs
	go run server.go

.PHONY: develop

