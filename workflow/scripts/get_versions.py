#!/usr/bin/python3

# GET_VERSIONS
# -----------------------------------------------------------------------------
#
# This script generates a MultiQC compatible software version yaml file from a
# tsv file.
# -----------------------------------------------------------------------------

import os
import pandas as pd
import yaml


input_tab = snakemake.input["versions"]
input_conf = snakemake.params["config"]
out_multi = snakemake.output["multi_conf"]
output_yml = snakemake.output["yaml"]
output_log = snakemake.log["path"]
log = []
error = []

try:
    version_dic = (
        pd.read_csv(input_tab, sep=",", header=None)
        .drop_duplicates()
        .reset_index(drop=True)
        .set_index(0)[1]
        .to_dict()
    )
except IOError:
    error += [f"Error occurred when reading input file '{input_tab}'."]

try:
    with open(input_conf, "r") as input_conf:
        config_dic = yaml.safe_load(input_conf)
except IOError:
    error += [f"Error occurred when reading input config '{input_conf}'."]

# software info to multiqc config
config_dic["software_versions"] = dict(version_dic)

try:
    with open(output_yml, "w") as out_yml:
        log += [f"Writing output YAML file '{output_yml}'..."]
        yaml.dump(version_dic, out_yml, default_flow_style=False)
except IOError:
    error += [f"Output file '{output_yml}' can not be opened."]


try:
    with open(out_multi, "w") as multi_yml:
        log += [f"Writing output YAML file '{out_multi}'..."]
        yaml.dump(config_dic, multi_yml, default_flow_style=False)
except IOError:
    error += [f"Output file '{output_yml}' can not be opened."]


# Remove input_tab file
try:
    os.remove(input_tab)
    log += f"File {input_tab} has been removed successfully."
except FileNotFoundError:
    error += [f"File '{input_tab}' not found."]

# print error/log messages
if error:
    print("\n".join(error))
    raise Exception("An error occurred, quitting.")
else:
    log += ["Module finished successfully\n"]
    log = ["GET_VERSIONS: " + i for i in log]
    with open(output_log, "w") as log_file:
        log_file.write("\n".join(log))
