#!/usr/bin/python

# MERGE COUNTS
# -----------------------------------------------------------------------------
#
# This script generates a summary count matrix of all samples

import pandas as pd

input_counts = snakemake.input["counts"]
input_summary = snakemake.input["summary"]
gtf = snakemake.input["gtf"]
sample_names = snakemake.params["samples"]
output = snakemake.output["table"]
output_log = snakemake.log["path"]
log = []
error = []

try:
    counts = [
        pd.read_table(f, index_col=0, usecols=[0, 6], header=None, skiprows=2)
        for f in input_counts
    ]
    log += ["Count tables imported."]
except ValueError:
    error += ["Pandas read table error. Usecols do not match colums."]

for t, sample in zip(counts, sample_names):
    t.columns = [sample]

df = pd.concat(counts, axis=1, sort=False)
df.index.name = "locus_tag"

try:
    gtf_cols = [
        "ref",
        "source",
        "feature_type",
        "start",
        "stop",
        "frame",
        "strand",
        "score",
        "attributes",
    ]
    biotypes = pd.read_table(gtf, names=gtf_cols, comment="#")

    bio_type = (
        pd.DataFrame(biotypes.attributes.apply(lambda x: x.split(";")).to_list())
        .loc[:, 2]
        .apply(lambda x: x.lstrip().split(" ")[1].replace('"', ""))
    )

    locus_tag = (
        pd.DataFrame(biotypes.attributes.apply(lambda x: x.split(";")).to_list())
        .loc[:, 3]
        .apply(lambda x: x.lstrip().split(" ")[1].replace('"', ""))
    )

    name = (
        pd.DataFrame(biotypes.attributes.apply(lambda x: x.split(";")).to_list())
        .loc[:, 4]
        .apply(lambda x: x.lstrip().split(" ")[1].replace('"', ""))
    )

    meta_info = pd.concat([locus_tag, name, bio_type], axis=1, sort=False)
    meta_info.columns = ["locus_tag", "gene_name", "biotype"]
    meta_info.set_index("locus_tag", inplace=True)

    log += ["Feature type information extracted."]
except OSError:
    error += [f"Error occurred when importing GTF file '{gtf}'."]

df_final = meta_info.merge(df, left_index=True, right_index=True)

# import feature counts summary tables
try:
    summary = [pd.read_table(f, index_col=0) for f in input_summary]

    for t, sample in zip(summary, sample_names):
        t.columns = [sample]
    log += ["FeatureCounts summary tables imported."]
except ValueError:
    error += [
        f"Pandas read table error when reading '{input_summary}'. Usecols do not match colums."
    ]

df_summary = pd.concat(summary, axis=1, sort=False)
df_no_feat = pd.DataFrame(
    3 * ["unassigned_noFeature"] + df_summary.loc["Unassigned_NoFeatures"].to_list()
).transpose()
df_final = df_final.reset_index()

# add no_feature information to counts table
df_no_feat.columns = df_final.columns
df_final = pd.concat([df_final, df_no_feat], axis=0, sort=False, ignore_index=True)
df_final.set_index("locus_tag", inplace=True)

try:
    df_final.to_csv(output, sep="\t")
except OSError:
    error += [f"Cannot write output table '{output}'."]

# print error/log messages
if error:
    print("\n".join(error))
    raise Exception("An error occurred, quitting.")
else:
    log += ["Module finished successfully\n"]
    log = ["MERGE COUNTS: " + i for i in log]
    with open(output_log, "w") as log_file:
        log_file.write("\n".join(log))
