package main

import (
	"fmt"
	"net/http"
	"os"
)

func handleAPI(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "hi there")
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
