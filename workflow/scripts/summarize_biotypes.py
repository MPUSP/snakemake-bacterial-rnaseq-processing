#!/usr/bin/python

# SUMMARIZE BIOTYPES
# -----------------------------------------------------------------------------
#
# This script generates summary table and plots the fraction of different biotypes

import pandas as pd

input_counts = snakemake.input["table"]
sample_names = snakemake.params["samples"]
output_counts = snakemake.output["tab_counts"]
output_fractions = snakemake.output["tab_fractions"]
output_log = snakemake.log["path"]
log = []
error = []

# import summarized sample counts
try:
    df_counts = pd.read_table(input_counts, sep="\t")
except ValueError:
    error += ["Pandas read table error."]

try:
    # export summarized biotype counts table
    df_biotypes = df_counts.groupby("biotype").sum()[sample_names].reset_index().copy()
    df_biotypes["biotype"] = df_biotypes["biotype"].replace("protein_coding", "mRNA")
    df_biotypes.to_csv(output_counts, index=False, sep="\t", quoting=3)

    df_bio_percent = df_biotypes.set_index("biotype").apply(
        lambda x: (x / x.sum()) * 100, axis=0
    )
    df_bio_percent.to_csv(output_fractions, sep="\t", quoting=3)
except OSError:
    error += [f"Cannot write output table '{output_counts}' or '{output_fractions}'."]

# print error/log messages
if error:
    print("\n".join(error))
    raise Exception("An error occurred, quitting.")
else:
    log += ["Module finished successfully\n"]
    log = ["SUMMARIZE BIOTYPES: " + i for i in log]
    with open(output_log, "w") as log_file:
        log_file.write("\n".join(log))
