package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"sync"
)

var filename = "data.json"

const PORT = "8081"

type ds struct {
	lock  sync.Mutex
	store map[string]any
}

func main() {
	// Check if there's the data.json
	if len(os.Args) < 2 {
		log.Fatalln("[ERROR] Not provided argoment")
	}

	log.Println("[INFO] Starting datastore at port", PORT)

	var datastore ds
	datastore.store = make(map[string]any)
	//loadFromFile(&datastore.store)
	data, err := os.ReadFile(os.Args[1])
	if err != nil {
		log.Fatalln("[ERROR] Not correct file provided")
	}
	json.Unmarshal(data, &datastore.store)

	/* if len(datastore.store) != 0 {
		log.Println("[INFO] Load content from", filename, "filename")
	} */

	mux := http.NewServeMux()

	mux.HandleFunc("GET /data", handleData(datastore.store))
	mux.HandleFunc("PUT /data/{key}", handleUpdate(datastore.store))
	mux.HandleFunc("POST /lock", handleLock(&datastore))
	mux.HandleFunc("DELETE /lock", handleUnlock(&datastore))

	log.Fatal(http.ListenAndServe(":"+PORT, mux))
}

func handleLock(datastore *ds) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		datastore.lock.Lock()
		log.Printf("Locked...")
	}
}

func handleUnlock(datastore *ds) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		err := saveToFile(datastore.store)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
		}
		datastore.lock.Unlock()
		log.Printf("Unlocked...")
	}
}

func loadFromFile(store *map[string]any) {
	data, err := os.ReadFile(filename)
	// if ReadFile is successufl, the error is nil
	if err == nil {
		json.Unmarshal(data, &store)
	}
}

func handleData(store map[string]any) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		data, err := json.Marshal(store)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.Write(data)
	}
}

func handleUpdate(store map[string]any) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		key := r.PathValue("key")
		body, err := io.ReadAll(r.Body)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
			return
		}
		var data any
		err = json.Unmarshal(body, &data)
		if err != nil {
			w.WriteHeader(http.StatusBadRequest)
			return
		}
		store[key] = data
		log.Printf("Set %q to %v", key, data)

		w.WriteHeader(http.StatusOK)
	}
}

func saveToFile(store map[string]any) error {
	data, err := json.Marshal(store)
	if err != nil {
		return err
	}
	return os.WriteFile(filename, data, 0644)
}
