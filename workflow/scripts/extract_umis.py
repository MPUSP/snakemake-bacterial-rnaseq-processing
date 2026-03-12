#!/usr/bin/python

#  EXTRACT UMIs
# -----------------------------------------------------------------------------
#
# This script takes as input two files in FASTQ format (w/o gzipped).
# R1 contains the actual sequence of the transcript and R2/R3 the UMI information
# depending on the sequencing type, i.e. single-end or paired-end.

import dnaio


def extract_umi(R1, R2, output, log, error):
    c = 0
    try:
        # read in two fastq files at the same time
        with dnaio.open(file1=R1, file2=R2, mode="r") as f:
            with dnaio.open(output, mode="w") as out:
                records = list(f)
                for record in records:
                    name = record[0].name.split(" ")
                    umi_name = f"{name[0]}_{record[1].sequence} {name[1]}"
                    record[0].name = umi_name
                    out.write(record[0])
                    c += 1
        f.close()
        out.close()
        log += [f"{c} reads written to output file."]
    except IOError:
        error += ["Error occured when processing input/output FASTQ files."]
        raise


# set input/output parameters
# ---------------------------
output_log = snakemake.log[0]
log = []
error = []

# paired-end
if len(snakemake.input) > 2:
    file_r1 = snakemake.input["fq1"]
    file_r2 = snakemake.input["fq2"]
    file_umis = snakemake.input["fqumi"]
    output_r1 = snakemake.output["fq1"]
    output_r2 = snakemake.output["fq2"]
    log += ["Processing R1 ..."]
    extract_umi(R1=file_r1, R2=file_umis, output=output_r1, log=log, error=error)
    log += ["Processing R2 ..."]
    extract_umi(R1=file_r2, R2=file_umis, output=output_r2, log=log, error=error)
# single-end
else:
    is_paired_end = False
    file_r1 = snakemake.input["fq1"]
    file_umis = snakemake.input["fqumi"]
    output_r1 = snakemake.output["fq1"]
    extract_umi(R1=file_r1, R2=file_umis, output=output_r1, log=log, error=error)


# print error / log messages
# ---------------------------
if error:
    print("\n".join(error))
    raise ValueError("Error occurred while processing FASTQ file, exit forced.")
else:
    log += ["Module finished successfully!\n"]
    log = ["EXTRACT_UMIS: " + i for i in log]
    with open(output_log, "w") as log_file:
        log_file.write("\n".join(log))
