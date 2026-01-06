# OWSM: OPA Wrapper State Manager
This section contains the experiments conducted for the article presented at ITASEC 2025.  
More details can be found in the publication at this [link](https://ceur-ws.org/Vol-3962/paper49.pdf).

## How to Replicate the Experiments
### Setup
Execute the following commands inside the `experiments` folder:

```
python3 -m venv venv
source ./venv/bin/activate
pip install -r ./graphs/requirments.txt
```

It will create a virtual Python environment.

### Run

Execute the `./run.sh` script to run the benchmark comparing OWSM and OPA.  
A folder named `results` will be created containing the measured execution times.

Once completed, run: `python ./graphs/main.py`.

Two directories will be generated: `exp-1` and `exp-2`.  
These contain the graphs comparing OWSM and OPA across the different use cases.
