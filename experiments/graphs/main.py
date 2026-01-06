import math
import pandas as pd
import matplotlib.pyplot as plt
import os
from scipy.stats import mannwhitneyu, wilcoxon, linregress

# Set global font sizes
plt.rc('axes', titlesize=22)     # Axes title
plt.rc('axes', labelsize=18)     # Axes labels
plt.rc('xtick', labelsize=18)    # X-axis tick labels
plt.rc('ytick', labelsize=18)    # Y-axis tick labels
plt.rc('legend', fontsize=18)    # Legend font size
plt.rc('font', size=10)          # Default font size
       
def exp1() :
    exp = "exp-1"

    # Step 1: Load the CSV data
    opa_csv_path = f"../results/{exp}/opa"
    owsm_csv_path = f"../results/{exp}/owsm"

    print(f"|- Considering experiment {exp}")

    data = pd.DataFrame(columns=["use_case", "num_requests", "mean_opa", "variance_opa", "iqr_opa", "mean_owsm", "variance_owsm", "iqr_owsm"])

    for file in os.listdir(opa_csv_path):
        opa_data = pd.read_csv(os.path.join(opa_csv_path, file), sep='\t', header=0)
        owsm_data = pd.read_csv(os.path.join(owsm_csv_path, file), sep='\t', header=0)

        """ result = mannwhitneyu(opa_data["ttime"].tolist(), owsm_data["ttime"].tolist())
        print("|-- U statistic:", result.statistic)
        print("|-- P-value:", result.pvalue) """

        # Step 2: Create a 'graphs' directory if it doesn't exist
        output_dir = '../results/exp-1'
        os.makedirs(output_dir, exist_ok=True)

        (base, _) = file.split(".")
        (use_case, num_requests) = base.split("-")

        #data.loc[len(data)] = {"use_case": int(use_case), "num_requests": int(num_requests), "mean_opa": opa_data["ttime"].mean(), "variance_opa": opa_data["ttime"].var(), "mean_owsm": owsm_data["ttime"].mean(), "variance_owsm": owsm_data["ttime"].var()}

        data.loc[len(data)] = {
            "use_case": int(use_case),
            "num_requests": int(num_requests),
            "mean_opa": opa_data["ttime"].mean(),
            "variance_opa": opa_data["ttime"].var(),
            "iqr_opa": (opa_data["ttime"].quantile(0.75) - opa_data["ttime"].quantile(0.25)),
            "mean_owsm": owsm_data["ttime"].mean(), 
            "variance_owsm": owsm_data["ttime"].var(),
            "iqr_owsm": (owsm_data["ttime"].quantile(0.75) - owsm_data["ttime"].quantile(0.25)),
        }

    for use_case in range(1,4):    
        use_case_data = data[data["use_case"] == use_case].copy().sort_values(by='num_requests')[:3]
        use_case_data.loc[len(use_case_data)] = {
            "use_case": use_case,
            "num_requests": 300,
            "mean_opa": 0,
            "variance_opa": 0,
            "iqr_opa": 0,
            "mean_owsm": 1250, 
            "variance_owsm": 0,
            "iqr_owsm": 0,
        }

        use_case_data = use_case_data.sort_values(by='num_requests')

        print(linregress([1,2,3,4],[1,1,1,1]))

        result = linregress(use_case_data["num_requests"], use_case_data["mean_owsm"])
        print("|-- Use case:", use_case)
        print(f"|--- R-squared: {result.rvalue**2}")
        print("|--- P-value:", result.pvalue)
        print("|--- M:", result.slope)

        use_case_data['std_dev_opa'] = use_case_data['variance_opa'] ** 0.5
        use_case_data['std_dev_owsm'] = use_case_data['variance_owsm'] ** 0.5

        # Plot
        plt.figure(figsize=(12, 7))

        plt.plot(use_case_data["num_requests"], result.intercept + result.slope*use_case_data["num_requests"], 'r', label='fitted line')

        # Plot OPA
        plt.errorbar(
            use_case_data['num_requests'],        # x-axis
            use_case_data['mean_opa'],            # y-axis
            yerr=use_case_data['iqr_opa'],    # Error bars (OPA std deviation)
            fmt='o--',                  # Line and marker style
            label='OPA'
        )

        # Plot OWSM
        plt.errorbar(
            use_case_data['num_requests'],        # x-axis
            use_case_data['mean_owsm'],           # y-axis
            yerr=use_case_data['iqr_owsm'],   # Error bars (OWSM std deviation)
            fmt='s--',                 # Line and marker style (different for clarity)
            label='OWSM'
        )

        # Set logarithmic scale for x-axis
        # plt.xscale('log')

        # Labels and title
        plt.xlabel('Number of Requests (log scale)')
        plt.ylabel('Time per request (µs)')
        #plt.title(f'OPA vs OWSM (use case {use_case})')
        plt.legend()
        plt.grid(True, which="both", linestyle='--', linewidth=0.5)

        plt.savefig(os.path.join(output_dir, str(use_case) + '-plot.png'))
        plt.close()

def exp2():
    exp = "exp-2l"

    # Step 1: Load the CSV data
    opa_csv_path = f"../results/{exp}/opa"
    owsm_csv_path = f"../results/{exp}/owsm"

    print(f"|- Considering experiment {exp}")

    data = pd.DataFrame(columns=["use_case", "concurrency", "mean_opa", "variance_opa", "iqr_opa", "mean_owsm", "variance_owsm", "iqr_owsm"])

    for file in os.listdir(opa_csv_path):
        opa_data = pd.read_csv(os.path.join(opa_csv_path, file), sep='\t', header=0)
        owsm_data = pd.read_csv(os.path.join(owsm_csv_path, file), sep='\t', header=0)

        # Step 2: Create a 'graphs' directory if it doesn't exist
        output_dir = '../results/exp-2'
        os.makedirs(output_dir, exist_ok=True)

        (base, _) = file.split(".")
        (use_case, concurrency) = base.split("-")

        data.loc[len(data)] = {
            "use_case": int(use_case),
            "concurrency": int(concurrency),
            "mean_opa": opa_data["ttime"].mean(),
            "variance_opa": opa_data["ttime"].var(),
            "iqr_opa": (opa_data["ttime"].quantile(0.75) - opa_data["ttime"].quantile(0.25)),
            "mean_owsm": owsm_data["ttime"].mean(), 
            "variance_owsm": owsm_data["ttime"].var(),
            "iqr_owsm": (owsm_data["ttime"].quantile(0.75) - owsm_data["ttime"].quantile(0.25)),
            }

    for use_case in range(1,4):
        use_case_data = data[data["use_case"] == use_case].copy().sort_values(by='concurrency')

        use_case_data['std_dev_opa'] = use_case_data['variance_opa'] ** 0.5
        use_case_data['std_dev_owsm'] = use_case_data['variance_owsm'] ** 0.5

        result = linregress(use_case_data["concurrency"].tolist(), use_case_data["mean_owsm"].tolist())
        print("|-- Use case:", use_case)
        print(f"|--- R-squared: {result.rvalue**2:.6f}")
        print("|--- P-value:", result.pvalue)

        print("max_iqr_opa", sum(use_case_data["iqr_opa"])/len(use_case_data["iqr_opa"]))
        print("max_iqr_owsm", sum(use_case_data["iqr_owsm"])/len(use_case_data["iqr_owsm"]))


        # Plot
        plt.figure(figsize=(12, 7))

        # Plot OPA
        plt.errorbar(
            use_case_data['concurrency'],        # x-axis
            use_case_data['mean_opa'],            # y-axis
            yerr=use_case_data['iqr_opa'],    # Error bars (OPA std deviation)
            fmt='o--',                  # Line and marker style
            label='OPA'
        )

        # Plot OWSM
        plt.errorbar(
            use_case_data['concurrency'],        # x-axis
            use_case_data['mean_owsm'],           # y-axis
            yerr=use_case_data['iqr_owsm'],   # Error bars (OWSM std deviation)
            fmt='s--',                 # Line and marker style (different for clarity)
            label='OWSM'
        )

        # Set logarithmic scale for x-axis
        #plt.xscale('log')
        #plt.yscale('log')

        # Labels and title
        plt.xlabel('Level of concurrency')
        plt.ylabel('Time per request (µs)')
        #plt.title(f'OPA vs OWSM (use case {use_case})')
        plt.legend()
        plt.grid(True, which="both", linestyle='--', linewidth=0.5)

        plt.savefig(os.path.join(output_dir, str(use_case) + '-plot.png'))
        plt.close()

exp1()
exp2()
