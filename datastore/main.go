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
	log.Println("[INFO] Starting datastore at port", PORT)

	var data ds
	data.store = make(map[string]any)
	loadFromFile(&data.store)

	if len(data.store) != 0 {
		log.Println("[INFO] Load content from", filename, "filename")
	}

	mux := http.NewServeMux()

	mux.HandleFunc("GET /data", handleData(data.store))
	mux.HandleFunc("PUT /data/{key}", handleUpdate(data.store))
	mux.HandleFunc("GET /lock", handleLock(&data))
	mux.HandleFunc("GET /unlock", handleUnlock(&data))

	log.Fatal(http.ListenAndServe(":8081", mux))
}

func handleLock(data *ds) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		data.lock.Lock()
		log.Printf("Locked...")
	}
}

func handleUnlock(data *ds) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		data.lock.Unlock()
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

		err = saveToFile(store)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
		}

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
