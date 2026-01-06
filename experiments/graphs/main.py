import os
import pandas as pd
import matplotlib.pyplot as plt
from scipy.stats import linregress

# Global matplotlib configuration
plt.rc('axes', titlesize=22)
plt.rc('axes', labelsize=18)
plt.rc('xtick', labelsize=18)
plt.rc('ytick', labelsize=18)
plt.rc('legend', fontsize=18)
plt.rc('font', size=10)

# Utility functions
def compute_iqr(series: pd.Series) -> float:
    return series.quantile(0.75) - series.quantile(0.25)


def load_experiment_data(
    exp: str,
    x_col: str,
) -> pd.DataFrame:
    """
    Load OPA and OWSM data for an experiment.

    Parameters
    ----------
    exp : str
        Experiment folder name (e.g., 'exp-1', 'exp-2l')
    x_col : str
        Independent variable name ('num_requests' or 'concurrency')

    Returns
    -------
    pd.DataFrame
    """
    opa_path = f"../results/{exp}/opa"
    owsm_path = f"../results/{exp}/owsm"

    rows = []

    for file in os.listdir(opa_path):
        opa = pd.read_csv(os.path.join(opa_path, file), sep='\t')
        owsm = pd.read_csv(os.path.join(owsm_path, file), sep='\t')

        base, _ = file.split(".")
        use_case, x_val = base.split("-")

        rows.append({
            "use_case": int(use_case),
            x_col: int(x_val),

            "mean_opa": opa["ttime"].mean(),
            "variance_opa": opa["ttime"].var(),
            "iqr_opa": compute_iqr(opa["ttime"]),

            "mean_owsm": owsm["ttime"].mean(),
            "variance_owsm": owsm["ttime"].var(),
            "iqr_owsm": compute_iqr(owsm["ttime"]),
        })

    return pd.DataFrame(rows)


def plot_use_case(
    df: pd.DataFrame,
    x_col: str,
    use_case: int,
    output_dir: str,
    fit_owsm: bool = False,
):
    """
    Plot OPA vs OWSM with error bars for one use case.
    """
    use_case_df = df[df["use_case"] == use_case].sort_values(x_col).copy()

    plt.figure(figsize=(12, 7))

    # Optional linear regression on OWSM
    if fit_owsm:
        result = linregress(use_case_df[x_col], use_case_df["mean_owsm"])
        plt.plot(
            use_case_df[x_col],
            result.intercept + result.slope * use_case_df[x_col],
            'r',
            label='OWSM fitted line'
        )

        print(f"|-- Use case {use_case}")
        print(f"|--- R-squared: {result.rvalue ** 2:.6f}")
        print(f"|--- P-value: {result.pvalue:.6e}")
        print(f"|--- Slope: {result.slope:.6f}")

    # OPA
    plt.errorbar(
        use_case_df[x_col],
        use_case_df["mean_opa"],
        yerr=use_case_df["iqr_opa"],
        fmt='o--',
        label='OPA'
    )

    # OWSM
    plt.errorbar(
        use_case_df[x_col],
        use_case_df["mean_owsm"],
        yerr=use_case_df["iqr_owsm"],
        fmt='s--',
        label='OWSM'
    )

    plt.xlabel(x_col.replace("_", " ").title())
    plt.ylabel("Time per request (µs)")
    plt.legend()
    plt.grid(True, which="both", linestyle="--", linewidth=0.5)

    os.makedirs(output_dir, exist_ok=True)
    plt.savefig(os.path.join(output_dir, f"{use_case}-plot.png"))
    plt.close()


# -----------------------------
# Experiments
# -----------------------------
def run_exp1():
    exp = "exp-1"
    print(f"|- Considering experiment {exp}")

    df = load_experiment_data(exp, x_col="num_requests")

    # Artificial extra point (as in original code)
    for use_case in range(1, 4):
        df = pd.concat([
            df,
            pd.DataFrame([{
                "use_case": use_case,
                "num_requests": 300,
                "mean_opa": 0,
                "variance_opa": 0,
                "iqr_opa": 0,
                "mean_owsm": 1250,
                "variance_owsm": 0,
                "iqr_owsm": 0,
            }])
        ], ignore_index=True)

    for use_case in range(1, 4):
        plot_use_case(
            df,
            x_col="num_requests",
            use_case=use_case,
            output_dir="../results/exp-1",
            fit_owsm=True
        )


def run_exp2():
    exp = "exp-2"
    print(f"|- Considering experiment {exp}")

    df = load_experiment_data(exp, x_col="concurrency")

    for use_case in range(1, 4):
        plot_use_case(
            df,
            x_col="concurrency",
            use_case=use_case,
            output_dir="../results/exp-2",
            fit_owsm=False
        )



# Main
if __name__ == "__main__":
    run_exp1()
    run_exp2()
