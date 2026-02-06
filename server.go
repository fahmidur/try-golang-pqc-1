package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
	"errors"
)

const port = 8043

type RootResponse struct {
	Method      string `json:"method"`
	RemoteAddr   string `json:"remote_addr"`
	URLPath string `json:"request_path"`
	SSLCurve    string `json:"ssl_curve"`
	Now         string `json:"now"`
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	resp := RootResponse{
		Now: time.Now().String(),
		Method:      r.Method,
		RemoteAddr:   r.RemoteAddr,
		URLPath: r.URL.Path,
	}
	if r.TLS != nil {
		resp.SSLCurve = r.TLS.CurveID.String()
	}
	json.NewEncoder(w).Encode(resp)
}

func fileExists(path string) bool {
	if _, err := os.Stat(path); err != nil && errors.Is(err, os.ErrNotExist) {
		return false
	}
	return true
}

func main() {
	http.HandleFunc("/", rootHandler)

	var crtPath string
	var keyPath string 
	if fileExists("/.dockerenv") {
		crtPath = "/opt/certs/pqc.crt"
		keyPath = "/opt/certs/pqc.key"
	} else {
		crtPath = "./certs/pqc.crt"
		keyPath = "./certs/pqc.key"
	}
	fmt.Printf("Using crtPath: %s\n", crtPath);
	fmt.Printf("Using keyPath: %s\n", keyPath);

	fmt.Printf("Starting https://0.0.0.0:%d\n", port)
	// ListenAndServeTLS requires certificate and key files
	err := http.ListenAndServeTLS(":8043", crtPath, keyPath, nil)
	if err != nil {
		fmt.Printf("HTTPS server failed: %v\n", err)
	}
}
