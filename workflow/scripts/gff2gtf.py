#!/usr/bin/python

# GFF2GTF
# -----------------------------------------------------------------------------
#
# This script converts a GFF file to a GTF file.

from os import path
from BCBio import GFF


input_gff = snakemake.input["gff"]
output_gtf = snakemake.output["gtf"]
output_log = snakemake.log["path"]
log = []
error = []


if not path.exists(input_gff):
    error += ["The parameter 'gff' is not a valid path to a GFF file"]


def gff_to_gtf(gff_file, gtf_file, error):
    try:
        with open(gff_file, "r") as in_handle, open(gtf_file, "w") as out_handle:
            in_handle.seek(0)
            strand = ""
            records = GFF.parse(in_handle)
            attr_list = ["ID", "Name", "gene_biotype", "locus_tag", "trivial_name"]

            # Iterate over features and write to the GTF file
            for record in records:
                for feature in record.features:
                    # Get attributes from GFF and format for GTF

                    # only export selected keys:
                    attributes = "; ".join(
                        f'{key} "{value[0]}"'
                        for key, value in feature.qualifiers.items()
                        if key in attr_list
                    )

                    if feature.location.strand == 1:
                        strand = "+"
                    elif feature.location.strand == -1:
                        strand = "-"

                    if feature.type == "remark":
                        out_handle.write(
                            f"##sequence-region {record.id} 1 {len(record.seq)}\n"
                        )
                    elif feature.type != "remark":
                        # Write GTF format
                        out_handle.write(
                            f'{record.id}\t{feature.qualifiers["source"][0]}\t{feature.type}\t'
                            f"{feature.location.start+1}\t{feature.location.end}\t"
                            f".\t{strand}\t.\t{attributes}\n"
                        )
    except IOError:
        error += [f"Supplied GFF/GTF file can not be opened."]


gff_to_gtf(input_gff, output_gtf, error)

# print error/log messages
if error:
    print("\n".join(error))
    raise ValueError(
        "Either location of supplied GFF file was not correct or list of features were not found, quitting"
    )
else:
    log += ["Module finished successfully\n"]
    log = ["GFF2GTF: " + i for i in log]
    with open(output_log, "w") as log_file:
        log_file.write("\n".join(log))
