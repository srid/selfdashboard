package main

import (
	"fmt"
	"net/http"
	"os"
)

func handleAPI(w http.ResponseWriter, r *http.Request) {
	url, err := getDataClipUrl()
	if err != nil {
		fmt.Fprintf(w, "opps: %v", err)
	}
	dataClip, err := fetch(url)
	if err != nil {
		fmt.Fprintf(w, "opps: %v", err)
	} else {
		fmt.Fprintf(w, "ok: %+v", dataClip)
	}
}

func main() {
	fs := http.FileServer(http.Dir("static"))
	http.Handle("/", fs)
	http.HandleFunc("/api", handleAPI)
	http.ListenAndServe(":"+getPort(), nil)
}

func getPort() string {
	port := os.Getenv("PORT")
	if port == "" {
		port = "4000"
	}
	return port
}

func getDataClipUrl() (string, error) {
	url := os.Getenv("DATACLIP_URL")
	if url == "" {
		return "", fmt.Errorf("DATACLIP_URL is not specified")
	}
	return url, nil
}
