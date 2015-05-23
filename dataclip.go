package main

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
)

type DataClip struct {
	Fields []string `json:"fields"`
	Types  []int    `json:"types"`
	Values []Value  `json:"values"`
}

// FIXME: How to represent mixed type list? In our case [String, Int]
type Value []string

func decode(data []byte) (*DataClip, error) {
	var dataClip DataClip
	err := json.Unmarshal(data, &dataClip)
	return &dataClip, err
}

func fetch(url string) (*DataClip, error) {
	if response, err := http.Get(url); err != nil {
		return nil, err
	} else {
		defer response.Body.Close()
		data, err := ioutil.ReadAll(response.Body)
		if err != nil {
			return nil, err
		} else {
			return decode(data)
		}
	}
}
