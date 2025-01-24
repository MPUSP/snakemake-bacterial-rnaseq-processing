#!/usr/bin/python

# GET_VERSIONS
# -----------------------------------------------------------------------------
#
# This script generates a MultiQC compatible software version yaml file from a
# conda envs file.
# -----------------------------------------------------------------------------

import os
import pandas as pd
import yaml


input_envs = snakemake.input["conda_envs"]
input_conf = snakemake.params["config"]
out_multi = snakemake.output["multi_conf"]
output_yml = snakemake.output["yaml"]
output_log = snakemake.log["path"]
log = []
error = []

version_dic = {}
try:
    with open(input_envs, "r") as conda_envs:
        for line in conda_envs:
            line = line.strip()
            if "=" in line:
                if line.startswith("-"):
                    soft, version = line.replace("- ", "").split("=")
                    version_dic[soft] = f"{version}"
except IOError:
    error += [f"Error occurred when processing input file '{input_envs}'."]

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


# print error/log messages
if error:
    print("\n".join(error))
    raise Exception("An error occurred, quitting.")
else:
    log += ["Module finished successfully\n"]
    log = ["GET_VERSIONS: " + i for i in log]
    with open(output_log, "w") as log_file:
        log_file.write("\n".join(log))
