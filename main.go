// Just a Go proxy to successfully fetch the Heroku DataClip
// Beacuse, I am unable to do this directly from Elm due to CORS restriction.
// ... for whatever reason.
package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

func handleAPI(w http.ResponseWriter, r *http.Request) {
	url, err := getDataClipUrl()
	if err != nil {
		httpError(w, err)
	}
	data, err := fetch(url)
	if err != nil {
		httpError(w, err)
	} else {
		fmt.Fprintf(w, "%s", string(data))
	}
}

func httpError(w http.ResponseWriter, err error) {
	http.Error(w, err.Error(), http.StatusInternalServerError)
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

func fetch(url string) ([]byte, error) {
	if response, err := http.Get(url); err != nil {
		return nil, err
	} else {
		defer response.Body.Close()
		return ioutil.ReadAll(response.Body)
	}
}
