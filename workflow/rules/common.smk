import itertools
import os
import pandas as pd
from snakemake.logging import logger


# read sample sheet
# -----------------------------------------------------
na_values = ["", "NaN", "nan", "null", "-"]
samples = (
    pd.read_csv(
        config["samplesheet"], sep="\t", dtype={"sample": str}, na_values=na_values
    )
    .set_index("sample", drop=False)
    .sort_index()
)


wildcard_constraints:
    sample="|".join(samples.index),
    read="|".join(["R1", "R2"]),


# helpers
# -----------------------------------------------------
experiment_types = list(samples["experiment"].unique())

is_single_end_experiment = False
is_paired_end_experiment = False
is_rnaseq_neb_umi = False
is_rnaseq_nextflex = False
is_rnaseq_neb_umi = False
is_rnaseq_mpusp_custom = False

# set flags based on experiment types
if "rnaseq_neb_umi" in experiment_types:
    is_rnaseq_neb_umi = True
if "rnaseq_nextflex" in experiment_types:
    is_rnaseq_nextflex = True
if "rnaseq_mpusp_custom" in experiment_types:
    is_rnaseq_mpusp_custom = True

# if any entry in fq2 is NaN -> single-end experiment
if samples["fq2"].isna().any():
    is_single_end_experiment = True

# if any entry in fq2 is not NaN -> paired-end experiment
if samples["fq2"].notna().any():
    is_paired_end_experiment = True


def validate_experiment_type(a, b, c=False):
    return sum([a, b, c]) == 1


# each rnaseq experiment type can only be used exclusively
if not validate_experiment_type(
    is_rnaseq_neb_umi, is_rnaseq_nextflex, is_rnaseq_mpusp_custom
):
    msg = "A single experiment type needs to be selected. Possible types are: [rnaseq_neb_umi, rnaseq_nextflex, rnaseq_mpusp_custom]."
    logger.error(msg)
    raise ValueError(msg)

# either single-end or paired-end sequencing allowed
if not validate_experiment_type(a=is_single_end_experiment, b=is_paired_end_experiment):
    msg = "All samples need to be sequenced either in single-end or paired-end mode in order to analyse them at once."
    logger.error(msg)
    raise ValueError(msg)


# set final output files
# -----------------------------------------------------
def get_final_output():
    return "results/report/multiqc_report.html"


# returns True if single-end
def is_single_end(sample):
    """Determine whether the sample is single-end."""
    fq2_not_present = pd.isnull(samples.loc[sample, "fq2"])
    return fq2_not_present


# get fastq files for qc input
def get_qc_input(wildcards):
    """Get QC input file."""
    inputs = []
    if wildcards.status == "raw":
        inputs.append(
            expand(
                "{input_dir}/{sample}",
                input_dir=samples.loc[wildcards.sample]["data_folder"],
                sample=samples.loc[wildcards.sample]["fq1"],
            )
        )
        if not is_single_end(wildcards.sample):
            # append R2 if sample is paired-end
            inputs.append(
                expand(
                    "{input_dir}/{sample}",
                    input_dir=samples.loc[wildcards.sample]["data_folder"],
                    sample=samples.loc[wildcards.sample]["fq2"],
                )
            )

    if wildcards.status == "clipped":
        if not is_single_end(wildcards.sample):
            inputs.append(
                expand(
                    os.path.join("results", "clipped", "{sample}_{read}.fastq.gz"),
                    sample=wildcards.sample,
                    read=["R1", "R2"],
                )
            )
        else:
            inputs.append(
                expand(
                    os.path.join("results", "clipped", "{sample}.fastq.gz"),
                    sample=wildcards.sample,
                )
            )
    return list(itertools.chain.from_iterable(inputs))


# get fastq files for umi extract input
def get_umi_input(wildcards):
    """Get FASTQ files UMI extraction."""
    inputs = []
    # three fastq files
    inputs.append(
        expand(
            "{input_dir}/{sample}",
            input_dir=samples.loc[wildcards.sample]["data_folder"],
            sample=samples.loc[wildcards.sample]["fq1"],
        )
    )
    if not is_single_end(wildcards.sample):
        # append R2 if sample is paired-end
        inputs.append(
            expand(
                "{input_dir}/{sample}",
                input_dir=samples.loc[wildcards.sample]["data_folder"],
                sample=samples.loc[wildcards.sample]["fq2"],
            )
        )

    # include third fastq file
    if is_rnaseq_neb_umi:
        inputs.append(
            expand(
                "{input_dir}/{sample}",
                input_dir=samples.loc[wildcards.sample]["data_folder"],
                sample=samples.loc[wildcards.sample]["fq_umi"],
            )
        )

    return list(itertools.chain.from_iterable(inputs))


# returns fastq files for trimming
def get_trimming_input(wildcards):
    """Get FASTQ files for trimming."""
    inputs = []
    if is_single_end_experiment:
        inputs.append(expand("results/umi_extract/{sample}.fastq.gz", sample=samples.index))

    elif is_paired_end_experiment:
        inputs.append(
            expand(
                "results/umi_extract/{sample}_{read}.fastq.gz",
                sample=samples.index,
                read=["R1", "R2"],
            )
        )

    return list(itertools.chain.from_iterable(inputs))


# returns fastq files for mapping
def get_mapping_input(wildcards):
    """Get FASTQ files for trimming."""
    inputs = []
    if is_single_end_experiment and (is_rnaseq_mpusp_custom or is_rnaseq_neb_umi):
        inputs.append(expand("results/clipped/{sample}.fastq.gz", sample=wildcards.sample))

    elif is_paired_end_experiment:
        inputs.append(
            expand(
                "results/umi_extract/{sample}_{read}.fastq.gz",
                sample=wildcards.sample,
                read=["R1", "R2"],
            )
        )

    return list(itertools.chain.from_iterable(inputs))


# return bam files for alignment qc
def get_stats_input(wildcards):
    if wildcards.step == "mapped":
        return expand(
            "results/mapped/{sample}.bam",
            sample=wildcards.sample,
        )
    if wildcards.step == "dedup":
        return expand(
            "results/deduplicated/{sample}.bam",
            sample=wildcards.sample,
        )


def construct_multiqc_input():
    inputs = []
    inputs.append(
        expand(
            "results/qc/{status}_reads/{sample}",
            status=["raw", "clipped"],
            sample=samples.index,
        ),
    )

    inputs.append(
        expand(
            "results/qc/{step}_alignment/{sample}_stats.txt",
            step=["mapped", "dedup"],
            sample=samples.index,
        )
    )

    return list(itertools.chain.from_iterable(inputs))
