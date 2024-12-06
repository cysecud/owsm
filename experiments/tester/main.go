package main

import (
	"bytes"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"time"
)

// checkURL checks if a URL is available by sending a HEAD request
func checkURL(url string, timeout time.Duration) bool {
	client := &http.Client{
		Timeout: timeout,
	}

	// Send a HEAD request
	resp, err := client.Head(url)
	if err != nil {
		fmt.Printf("Error checking URL %s: %v\n", url, err)
		return false
	}
	defer resp.Body.Close()

	fmt.Printf("URL %s is available.\n", url)
	return true
}

func main() {
	// Define the two URLs and the number of requests
	owsm_url := "http://wrapper:8080/query"
	opa_url := "http://opa:8181/v1/data/examplerego"
	numRequests := 1000

	// Read the JSON payload from a file provided as argument
	jsonFilePath := os.Args[1]
	payloadBytes, err := os.ReadFile(jsonFilePath)
	if err != nil {
		fmt.Printf("Error reading JSON file: %v\n", err)
		return
	}

	// Validate the JSON structure
	var payload map[string]interface{}
	if err := json.Unmarshal(payloadBytes, &payload); err != nil {
		fmt.Printf("Error parsing JSON file: %v\n", err)
		return
	}
	fmt.Println("JSON payload successfully read and parsed.")

	// Open a CSV file for writing
	file, err := os.Create("./results/results" + os.Getenv("USE_CASE") + ".csv")
	if err != nil {
		fmt.Printf("Error creating file: %v\n", err)
		return
	}
	defer file.Close()

	// Create a CSV writer
	writer := csv.NewWriter(file)
	defer writer.Flush()

	// Write the header row to the CSV
	writer.Write([]string{"number_request", "OWSM", "OPA"})

	// Timeout for each check
	timeout := 5 * time.Second

	// Check availability of all URLs
	allAvailable := false

	for !allAvailable {
		if checkURL(owsm_url, timeout) && checkURL(opa_url, timeout) {
			allAvailable = true
		}
	}

	// Perform the requests and record the times
	for i := 1; i <= numRequests; i++ {
		// Measure time for URL1
		start1 := time.Now()
		resp1, err1 := http.Post(owsm_url, "application/json", bytes.NewBuffer(payloadBytes))
		if err1 != nil {
			fmt.Printf("Error with request to %s: %v\n", owsm_url, err1)
			continue
		}
		resp1.Body.Close()
		elapsed1 := time.Since(start1) // Time in milliseconds

		// Measure time for URL2
		start2 := time.Now()
		resp2, err2 := http.Post(opa_url, "application/json", bytes.NewBuffer(payloadBytes))
		if err2 != nil {
			fmt.Printf("Error with request to %s: %v\n", opa_url, err2)
			continue
		}
		resp2.Body.Close()
		elapsed2 := time.Since(start2) // Time in milliseconds

		// Write the results to the CSV
		writer.Write([]string{
			fmt.Sprintf("%d", i),        // number_request
			fmt.Sprintf("%d", elapsed1), // url1 elapsed time in milliseconds
			fmt.Sprintf("%d", elapsed2), // url2 elapsed time in milliseconds
		})

		// Print progress for the user
		fmt.Printf("Request %d completed: url1=%dms, url2=%dms\n", i, elapsed1, elapsed2)
	}

	fmt.Println("Measurement completed. Results saved in results.csv")
	os.Create("./results/.done")
}
