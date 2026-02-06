FROM golang:1.25-bookworm

RUN apt update -y
RUN apt install -y \
    build-essential \
    cmake \
    curl \
    git \
    libssl-dev \
    ninja-build \
    openssl \
    vim-tiny \
    wget

# Create a self-signed cert
RUN mkdir /opt/certs
WORKDIR /opt/certs
RUN openssl req -x509 -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /opt/certs/pqc.key \
  -out /opt/certs/pqc.crt \
  -subj "/C=US/ST=California/L=Los Angeles/O=Example/OU=IT/CN=echo-pqc-1.lvh.me"

RUN mkdir /opt/certs_export/

RUN mkdir /opt/main
WORKDIR /opt/main
# COPY ./entrypoint.sh .
COPY . .
ENTRYPOINT ["/opt/main/entrypoint.sh"]


