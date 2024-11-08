# OPA-WRAPPER STATE MANAGER

This is a simple Go wrapper around OPA! 
It allows saving the state of evaluated rules written in Rego.

More precisely it saves the ***state*** composite value of Rego, in the **datastore** server

## Installation
Clone this repository using git:

`git clone https://github.com/ffabionski/opawrapper-statemanager.git`

## How to use

### Using docker compose
The easiest way to run the program is to use docker compose.
Before do anything, create a ".env" in the root of the folder.
Then, paste this content and substitute *filename* with one name of policies' folder (mantain the double quotes!). 

```
POLICY_FILE="filename"
```

At the end, still in the root folder, you can execute `docker compose up` to start the program.


### Manual setp

1 - Run the **datastore**:

```bash
cd datastore
go run main.go
```

2 - Run the **opawrap**:

```bash
cd opawrap
go run main.go ../examplerego/rule-File.rego
```

where *rule-File.rego* is either *comm.rego* or *counter.rego* in the *examplerego* dir

use a tool like Yaak (or simply CURL) to make request to the endpoint provided by datastore and opawrap

## Examples

### Counter
Let's see how to use the **OPA-Wrapper State Manager** with the counter example.

1. Make a PUT request to the ***/data/counter*** API of datastore in order to save the initial value of the counter (this will be used as the initial data.json)

```bash
curl -X PUT 'http://localhost:8081/data/counter' \
  --header 'Content-Type: application/json' \
  --data-raw $'5'
```

In alternative, you can create a data.json in the *datastore* dir and fill it out accordingly.
For example:

```json
{
   "counter": 5
}
```

2. Check that the request was successful

```bash
curl -X GET 'http://localhost:8081/data'
```

3. Use the ***/query*** endpoint of opawrap to make a query.
In this example the input can be empty, because the counter.rego doesn't make any decision w.r.t. the input

```bash
curl -X POST 'http://localhost:8080/query' \
  --header 'Content-Type: application/json' \
  --data-raw $'{}'
```

4. Repeat the last command various time, at some point we will encounter

```json
{
  "allow": false
}
```

that's because the counter was decremented to 0

### Communication

In order to use the comm.rego example the steps are the same, with the appropiate changes:

1 - PUT method to ***/data/ab*** endpoint of datastore
```bash
curl -X PUT 'http://localhost:8081/data/ab' \
  --header 'Content-Type: application/json' \
  --data-raw $'false'
```

2 - Check that the PUT method was effective
```bash
curl -X GET 'http://localhost:8081/data'
```

3 - the call to the ***/query*** endpoint needs an input, for example

```bash
curl -X POST 'http://localhost:8080/query' \
  --header 'Content-Type: application/json' \
  --data-raw $'{
  "source": "b",
  "dest": "c"
}'
```

In this example ***b*** can communicate with ***c*** until ***a*** start to communicate with ***b***.
