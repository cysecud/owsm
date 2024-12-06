import pandas as pd
import matplotlib.pyplot as plt
import os
from scipy.stats import mannwhitneyu

# Step 1: Load the CSV data
dir_path_1 = './ex1/results/'  # Replace with your file's path

print("|- Considering experiment 1")
for file in os.listdir(dir_path_1):
    data = pd.read_csv(os.path.join(dir_path_1, file))

    # Step 2: Create a 'graphs' directory if it doesn't exist
    output_dir = 'graphs/ex1'
    os.makedirs(output_dir, exist_ok=True)

    # Step 3: Generate a box plot
    plt.figure(figsize=(8, 6))
    data[['OWSM', 'OPA']].boxplot()
    plt.title('Box Plot')
    #plt.yscale("log")
    plt.savefig(os.path.join(output_dir, os.path.splitext(os.path.basename(file))[0] + '-boxplot.png'))
    plt.close()

    plt.figure(figsize=(8, 6))
    plt.plot(data['number_request'], data['OWSM'], "o", color="red")  # Replace with relevant column names
    plt.plot(data['number_request'], data['OPA'], "x", color="blue")
    plt.title('Comparison ' + file)
    ax=plt.gca()
    ax.legend(["OWSM", "OPA"])
    plt.xlabel('Number of request')  # Replace with relevant column name
    plt.ylabel('Elapsed time (ms)')  # Replace with relevant column name
    plt.savefig(os.path.join(output_dir, os.path.splitext(os.path.basename(file))[0] + '-plot.png'))
    plt.close()

    print("|-- Plot saved")

    # Perform the Mann-Whitney U test
    result = mannwhitneyu(data['OWSM'], data['OPA'])

    # Display the results
    print("|-- U statistic:", result.statistic)
    print("|-- P-value:", result.pvalue)

""" dir_path_2 = './ex2/results/' 

for file in os.listdir(dir_path_2):
    data = pd.read_csv(os.path.join(dir_path_2, file))

    output_dir = 'graphs/ex2'
    os.makedirs(output_dir, exist_ok=True)

    # Step 4: Generate a scatter plot
    plt.figure(figsize=(8, 6))
    plt.plot(data['requests'], data['owsm_avg_time_ms'], "o", alpha=0.7, color="red", )  # Replace with relevant column names
    plt.plot(data['requests'], data['opa_avg_time_ms'], "x", alpha=0.7, color="blue", markeredgewidth = 2)
    plt.title('Comparison' + file)
    ax=plt.gca()
    ax.legend(["OWSM", "OPA"])
    plt.xlabel('Number of concurrent requests')  # Replace with relevant column name
    plt.ylabel('Elapsed time (ms)')  # Replace with relevant column name
    plt.savefig(os.path.join(output_dir, file + '.png'))
    plt.close()


    # Sample data

    # Perform the Mann-Whitney U test
    result = mannwhitneyu(data['owsm_avg_time_ms'], data['opa_avg_time_ms'])

    # Display the results
    print("U statistic:", result.statistic)
    print("P-value:", result.pvalue)



dir_path_3 = './ex3/results/' 

for file in os.listdir(dir_path_3):
    data = pd.read_csv(os.path.join(dir_path_3, file))

    output_dir = 'graphs/ex3'
    os.makedirs(output_dir, exist_ok=True)

    plt.figure(figsize=(8, 6))
    plt.plot(data['requests'], data['owsm_avg_time_ms'], "o", alpha=0.7, color="red", )  # Replace with relevant column names
    plt.plot(data['requests'], data['opa_avg_time_ms'], "x", alpha=0.7, color="blue", markeredgewidth = 2)
    plt.title('Comparison' + file)
    ax=plt.gca()
    ax.legend(["OWSM", "OPA"])
    plt.xlabel('Number of concurrent requests')  # Replace with relevant column name
    plt.ylabel('Elapsed time (ms)')  # Replace with relevant column name
    plt.savefig(os.path.join(output_dir, file + '.png'))
    plt.close()
 """
    