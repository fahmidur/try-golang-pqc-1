# README

The purpose of this repo is to try out Golang 1.25's default PQC settings 
in an HTTPS server.

Notice that this is only testing the use of PQC algorithms for key exchange, 
and not for certificates. The self-signed cert used for the tests
here is still your usual RSA-based x509 cert.

## Quick Start

This repo defines a simple docker image built on `golang:1.25-bookworm`.

I'm using docker-compose here because it simplifies port-forwarding between the host and guest.

To get started simply run:

```
docker compose up
```

And now in your host browser or other HTTPS client of choice, you can visit:
```
https://echo-pqc-1.lvh.me:8043
```

I'm using lvh.me as an external DNS service which resolves to `127.0.0.1`.

The Golang server is using a self-signed cert that was created with the Docker image.
So you will get an untrusted certificate error. If you want to not get this error,
you must import the self-signed cert which is exposed to the host in `./certs_export/pqc.crt`.
But, since we are only using PQC for key-exchange, and not the certificate, it's not really all 
that important to import the certificate into your browser/https-client. It is there if you care.

Now you can see if your browser or HTTPS-client, is using a PQC curve for key exchange.
The echo service, running in the container will, among other things, echo 
in the JSON output the SSLCurve that is used by the TLS connection.

Side note: I recommend using a JSON Formatter/Prettifier plugin for your browser, as it makes viewing JSON 
responses from various HTTP(S) services, like this one, more convenient. Alternatively, if you're using CURL, 
you can pipe the output to something like `jq`.

Here is a sample output:

```
{
"method": "GET",
"remote_addr": "[::1]:60334",
"request_path": "/",
"ssl_curve": "X25519MLKEM768",
"now": "2026-02-06 11:22:05.363564152 -0800 PST m=+18.627384819"
}
```

We can see that on a relatively up-to-date version of Google Chrome (142.0.7444.175), 
a PQC hybrid curve is being used. 

Feel free to test with other browsers and other HTTPS clients. 


## FAQ

Q: When did Golang start using PQC Curves by default?

The change seems to have occurred at [Go v1.24](https://go.dev/doc/go1.24).
See this highlighted part of the release notes:

```
The new post-quantum X25519MLKEM768 key exchange mechanism is now supported
and is enabled by default when Config.CurvePreferences is nil. GODEBUG
setting tlsmlkem=0 reverts the default. This can be useful when dealing with
buggy TLS servers that do not handle large records correctly, causing a
timeout during the handshake (see TLS post-quantum TL;DR fail).
```

Q: What part of the code enables this default behavior?

At current Golang Master, the part of the code enabling this default selection
appears to be located here: [Link to crypto/tls/defaults.go](https://github.com/golang/go/blob/e2a34c7e9b04564ddad50bd7ec7b52fabde74192/src/crypto/tls/defaults.go#L21C1-L35C1)

```golang
func defaultCurvePreferences() []CurveID {
	switch {
	// tlsmlkem=0 restores the pre-Go 1.24 default.
	case tlsmlkem.Value() == "0":
		return []CurveID{X25519, CurveP256, CurveP384, CurveP521}
	// tlssecpmlkem=0 restores the pre-Go 1.26 default.
	case tlssecpmlkem.Value() == "0":
		return []CurveID{X25519MLKEM768, X25519, CurveP256, CurveP384, CurveP521}
	default:
		return []CurveID{
			X25519MLKEM768, SecP256r1MLKEM768, SecP384r1MLKEM1024,
			X25519, CurveP256, CurveP384, CurveP521,
		}
	}
}
```

