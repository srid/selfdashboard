package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
)

type DataClip struct {
	Fields    []string            `json:"fields"`
	Types     []int               `json:"types"`
	ValuesRaw [][]json.RawMessage `json:"values"`
	Values    []Value
}

func (clip *DataClip) decodeValues() error {
	for _, valueRaw := range clip.ValuesRaw {
		value, err := decodeValue(valueRaw)
		if err != nil {
			return err
		}
		clip.Values = append(clip.Values, value)
	}
	return nil
}

func decodeValue(data []json.RawMessage) (Value, error) {
	var value Value
	if len(data) != 2 {
		return value, fmt.Errorf("Invalid length")
	}

	err := json.Unmarshal(data[0], &value.Field)
	if err == nil {
		err = json.Unmarshal(data[1], &value.Value)
	}
	return value, err
}

type Value struct {
	Field string
	Value int
}

func decode(data []byte) (*DataClip, error) {
	var dataClip DataClip
	err := json.Unmarshal(data, &dataClip)
	if err == nil {
		err = dataClip.decodeValues()
	}
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
			fmt.Printf("Received body: %v\n", string(data))
			return decode(data)
		}
	}
}
