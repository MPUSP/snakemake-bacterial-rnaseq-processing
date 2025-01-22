#!/usr/bin/python

# SUMMARIZE BIOTYPES
# -----------------------------------------------------------------------------
#
# This script generates summary table and plots the fraction of different biotypes

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

input_counts = snakemake.input["table"]
sample_names = snakemake.params["samples"]
output_counts = snakemake.output["tab_counts"]
output_fractions = snakemake.output["tab_fractions"]
output_fig = snakemake.output["fig"]
output_log = snakemake.log["path"]
log = []
error = []

# import summarized sample counts
try:
    df_counts = pd.read_table(input_counts, sep="\t")
    # sel_samples = df_counts.columns[3:]
except ValueError:
    error += ["Pandas read table error."]

try:
    # export summarized biotype counts table
    df_biotypes = df_counts.groupby("biotype").sum()[sample_names].reset_index().copy()
    df_biotypes["biotype"] = df_biotypes["biotype"].replace("protein_coding", "mRNA")
    df_biotypes["biotype"] = df_biotypes["biotype"].replace(
        "unassigned_noFeature", "unassigned"
    )
    df_biotypes.to_csv(output_counts, index=False, quoting=3)

    df_bio_percent = df_biotypes.set_index("biotype").apply(
        lambda x: (x / x.sum()) * 100, axis=0
    )
    df_bio_percent.to_csv(output_fractions, quoting=3)
except OSError:
    error += [f"Cannot write output table '{output_counts}' or '{output_fractions}'."]

# plot biotype fraction
df_biotypes_long = pd.melt(
    df_bio_percent.reset_index(),
    id_vars="biotype",
    var_name="sample",
    value_name="count",
)

# set plotting style
sns.set_style("whitegrid")

fig, ax = plt.subplots()
sns.barplot(
    data=df_biotypes_long,
    x="biotype",
    y="count",
    hue="sample",
    errorbar=None,
    palette="Set1",
    ax=ax,
)

ax.set_title("Biotype Distribution")
ax.set_xlabel("")
ax.set_ylabel("Percent (%)")
ax.legend(title="Sample")
fig.savefig(output_fig, bbox_inches="tight")
plt.show()

# print error/log messages
if error:
    print("\n".join(error))
    raise Exception("An error occurred, quitting.")
else:
    log += ["Module finished successfully\n"]
    log = ["SUMMARIZE BIOTYPES: " + i for i in log]
    with open(output_log, "w") as log_file:
        log_file.write("\n".join(log))
