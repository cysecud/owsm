# OPA-WRAPPER STATE MANAGER

This is a simple Go wrapper around OPA! 
It allows saving the state of evaluated rules written in Rego.

More precisely it saves the ***state*** composite value of Rego, in the **datastore** server

### There are two main ways to try the wrapper:

1) Using ``` go run ``` and then ```curl``` commands
2) Using the ```compose file``` and running the scripts

### First Method
1 - Run the **datastore**:

```bash
cd datastore
go run main.go
```

2 - Run the **opawrap**:

```bash
cd opawrap
go run main.go ../policies/rule-File.rego
```

where *rule-File.rego* is either *comm.rego* or *counter.rego* in the *examplerego* dir

use a tool like Yaak (or simply CURL) to make request to the endpoint provided by datastore and opawrap

Let's see how to use the **OPA-Wrapper State Manager** with the counter example...

First, make a PUT request to the ***/data/counter*** API of datastore in order to save the initial value of the counter (this will be used as the initial data.json)

```bash
curl -X PUT 'http://localhost:8081/data/counter' \
  --header 'Content-Type: application/json' \
  --data-raw $'5'
```

In alternative, you can create a data.json in the *datastore* dir and fill it out accordingly. For example:

```json
{
   "counter": 5
}
```

Then we check that the request was successful

```bash
curl -X GET 'http://localhost:8081/data'
```

Next, we will use the ***/query*** endpoint of opawrap to make a query.
In this example the input has to be a JSON with a user.
The counter.rego policy allowes the access only if the user is ***fabio***

```bash
curl -X POST 'http://localhost:8080/query' \
  --header 'Content-Type: application/json' \
  --data-raw $'{
  "user": "fabio"
}'
```

If we repeat the last command various time, at some point we will encounter

```json
{
  "allow": false
}
```

that's because the counter was decremented to 0


In order to use the comm.rego example the steps are the same, with the appropiate changes:

1 - PUT method to ***/data/a_to_b*** endpoint of datastore
```bash
curl -X PUT 'http://localhost:8081/data/a_to_b' \
  --header 'Content-Type: application/json' \
  --data-raw $'false'
```

2 - Check that the PUT method was effective
```bash
curl -X GET 'http://localhost:8081/data'
```

3 - The call to the ***/query*** endpoint needs an input, for example

```bash
curl -X POST 'http://localhost:8080/query' \
  --header 'Content-Type: application/json' \
  --data-raw $'{
  "source": "b",
  "dest": "c"
}'
```

In this example ***b*** can communicate with ***c*** until ***a*** start to communicate with ***b***.

4 - If we make this query

```json
curl -X POST 'http://localhost:8080/query' \
  --header 'Content-Type: application/json' \
  --data-raw $'{
  "source": "a",
  "dest": "b"
}'
```

***a*** starts to communicate with ***b***

5 - The value of ***a_to_b*** is now true
```bash
curl -X GET 'http://localhost:8081/data'
```

6 - From now on this query

```bash
curl -X POST 'http://localhost:8080/query' \
  --header 'Content-Type: application/json' \
  --data-raw $'{
  "source": "b",
  "dest": "c"
}'
```

will return

```json
{
   "allow": false
}
```

### Second Method

1 - We can choose with which policy execute the wrapper, manipulating the ```compose.yml``` file.
If you open it you will encounter this line of code (in the wrapper service):

```yml
- /policies/counter.rego # or /policies/comm.rego
```

2 - Run the docker-compose file, be sure to be in the same directory of the *compose.yml* file.

```bash
docker compose up
```

3 - Move to the scripts folder

```bash
cd scripts
```

If in step 1 you chose ```/policies/counter.rego ```, then you need to run

```bash
./counter.sh
```

Otherwise you need to run

```bash
./threemicro.sh
```