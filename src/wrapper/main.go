package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"

	"opawrap/queryeval"
)

const PORT = "8080"

type Wrapper struct {
	client       http.Client
	datastoreUrl *url.URL
}

func main() {
	datastoreHost, ok := os.LookupEnv("DATASTORE_URL")
	if !ok {
		datastoreHost = "localhost"
	}

	datastoreUrl := &url.URL{
		Scheme: "http",
		Host:   datastoreHost + ":8081",
	}

	wrapper := Wrapper{
		client:       http.Client{},
		datastoreUrl: datastoreUrl,
	}

	log.Println("[INFO] Starting opawrap at port", PORT)

	mux := http.NewServeMux()

	mux.HandleFunc("POST /query", wrapper.handleQuery)

	log.Fatal(http.ListenAndServe(":8080", mux))
}

func (a *Wrapper) handleQuery(w http.ResponseWriter, r *http.Request) {

	// Searching for env variable DATASTORE_URL
	// otherwise using localhost

	// lock datastore
	// a.lock(w)

	// retrieve input to send to the policy engine
	body, err := io.ReadAll(r.Body)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	var input any
	err = json.Unmarshal(body, &input)
	if err != nil {
		http.Error(w, "invalid input of the query", http.StatusBadRequest)
		return
	}

	log.Println("[INFO] Received input")

	var data map[string]any
	a.getState(&data, w)

	state, result := queryeval.Opa(data, input, w, r.Context())

	log.Println("Output and new state extracted from OPA")

	a.updateState(state, w)

	log.Println("Sent new state to datastore")

	// unlock datastore
	// a.unlock(w)

	// Return only necessary output (i.e. without state part) to user
	output, err := json.Marshal(result)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(output)
	log.Println("Output to the client")
}

/*
 * Makes a GET request to datastore's API, in order to retrieve the actual state
 *
 * baseURL - the URL of datastore server
 * state - variable that will contain the actual state
 * w - to handle http errors
 */
func (a *Wrapper) getState(state *map[string]any, w http.ResponseWriter) {
	url := fmt.Sprintf("%s/data", a.datastoreUrl.String())
	resp, err := a.client.Get(url)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	dataBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	//var data map[string]any
	err = json.Unmarshal(dataBytes, &state)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}

/*
 * Makes a POST request to datastore's API, in order to update the state
 *
 * baseURL - the URL of datastore server
 * state - variable that contains the new state
 * w - to handle http errors
 */
func (a *Wrapper) updateState(state map[string]any, w http.ResponseWriter) {
	for key, value := range state {
		url := fmt.Sprintf("%s/%s", a.datastoreUrl.String(), path.Join("/data", key))
		bodyBytes, err := json.Marshal(value)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		body := io.NopCloser(bytes.NewBuffer(bodyBytes))
		req, err := http.NewRequest(http.MethodPut, url, body)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		_, err = a.client.Do(req)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}
}

func (a *Wrapper) lock(w http.ResponseWriter) {
	url := fmt.Sprintf("%s/lock", a.datastoreUrl.String())
	req, err := http.NewRequest(http.MethodPost, url, nil)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	_, err = a.client.Do(req)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}

func (a *Wrapper) unlock(w http.ResponseWriter) {
	url := fmt.Sprintf("%s/lock", a.datastoreUrl.String())
	req, err := http.NewRequest(http.MethodDelete, url, nil)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	_, err = a.client.Do(req)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}
