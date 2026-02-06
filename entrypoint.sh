#!/bin/bash

# Copy self-signed cert created during image-build into the cert_export directory.
# This is for the host to import into browsers/https-clients for testing.
mkdir -p /opt/certs_export
cp /opt/certs/* /opt/certs_export/
echo <<EOF > /opt/certs/README.md
# README

The certs in this directory are in use by the Docker container, and exported
here for your convenience. You may import these certs into your browser or use
them with your https-client of choice.

EOF

exec go run server.go

