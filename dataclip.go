package main

import (
	"io/ioutil"
	"net/http"
)

func fetch(url string) ([]byte, error) {
	if response, err := http.Get(url); err != nil {
		return nil, err
	} else {
		defer response.Body.Close()
		return ioutil.ReadAll(response.Body)
	}
}
