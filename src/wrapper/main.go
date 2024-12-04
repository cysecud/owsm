package main

import (
	"bytes"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"net/url"
	"os"
	"path"

	"opawrap/queryeval"
)

const PORT = "8080"

func main() {
	log.Println("[INFO] Starting opawrap at port", PORT)

	mux := http.NewServeMux()

	mux.HandleFunc("POST /query", handleQuery)

	log.Fatal(http.ListenAndServe(":8080", mux))
}

func handleQuery(w http.ResponseWriter, r *http.Request) {

	// Searching for env variable DATASTORE_URL
	// otherwise using localhost
	datastoreUrl, ok := os.LookupEnv("DATASTORE_URL")
	if !ok {
		datastoreUrl = "localhost"
	}

	baseURL := &url.URL{
		Scheme: "http",
		Host:   datastoreUrl + ":8081",
	}

	// lock datastore
	// lock(baseURL, w)

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
	getState(baseURL, &data, w)

	state, result := queryeval.Opa(data, input, w, r.Context())

	log.Println("Output and new state extracted from OPA")

	updateState(baseURL, state, w)

	log.Println("Sent new state to datastore")

	// unlock datastore
	// unlock(baseURL, w)

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
func getState(baseURL *url.URL, state *map[string]any, w http.ResponseWriter) {
	baseURL.Path = "data"
	client := http.Client{}
	resp, err := client.Get(baseURL.String())
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
func updateState(baseURL *url.URL, state map[string]any, w http.ResponseWriter) {
	for key, value := range state {
		baseURL.Path = path.Join("/data", key)
		bodyBytes, err := json.Marshal(value)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		body := io.NopCloser(bytes.NewBuffer(bodyBytes))
		client := http.Client{}
		req, err := http.NewRequest(http.MethodPut, baseURL.String(), body)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		_, err = client.Do(req)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
	}
}

func lock(baseURL *url.URL, w http.ResponseWriter) {
	baseURL.Path = "lock"
	client := http.Client{}
	req, err := http.NewRequest(http.MethodPost, baseURL.String(), nil)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	_, err = client.Do(req)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}

func unlock(baseURL *url.URL, w http.ResponseWriter) {
	baseURL.Path = "lock"
	client := http.Client{}
	req, err := http.NewRequest(http.MethodDelete, baseURL.String(), nil)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	_, err = client.Do(req)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
}
