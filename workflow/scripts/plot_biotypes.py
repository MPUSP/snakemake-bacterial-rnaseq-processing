#!/usr/bin/python

# PLOT BIOTYPES
# -----------------------------------------------------------------------------
#
# This script extracts biotype distribution data and generates a multiqc
# compatible json file to include a bargraph of of biotypes.

import pandas as pd
import json

input = snakemake.input["table"]
gtf = snakemake.input["gtf"]
output = snakemake.output["json"]
output_log = snakemake.log["path"]
log = []
error = []

# import summarized biotype counts
try:
    df = pd.read_table(input, index_col=0, sep="\t")
    log += ["Biotype counts imported."]
except OSError:
    error += ["Pandas read table error."]

# data_dic = df.set_index('biotype').to_dict()
data_dic = df.to_dict()

# generate barplot data
bar_graph = {}
bar_graph["id"] = "biotypes"
bar_graph["section_name"] = "Biotype Distribution"
bar_graph["description"] = (
    f"Biotype statistics were calculated using featureCounts and the provided genomic feature information file: <code>{gtf}</code>"
)
bar_graph["plot_type"] = "bargraph"
bar_graph["anchor"] = "biotype_dist"
bar_graph["pconfig"] = dict(title="Biotype Distribution")
bar_graph["data"] = data_dic

try:
    log += ["Writing json file..."]
    with open(output, "w") as json_file:
        json.dump(bar_graph, json_file, indent=4)
except IOError:
    error += ["Error occurred. Cannot write json file '{output}'."]

# print error/log messages
if error:
    print("\n".join(error))
    raise Exception("An error occurred, quitting.")
else:
    log += ["Module finished successfully\n"]
    log = ["PLOT BIOTYPES: " + i for i in log]
    with open(output_log, "w") as log_file:
        log_file.write("\n".join(log))
