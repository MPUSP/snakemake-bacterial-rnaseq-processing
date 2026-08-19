import pandas as pd
from snakemake.logging import logger
from snakemake.utils import validate
from pathlib import Path

# read sample sheet
# -----------------------------------------------------
samples = (
    pd.read_csv(
        config["samplesheet"],
        sep="\t",
        dtype={"sample": str},
        na_values=["", "NaN", "nan", "null", "-"],
    )
    .set_index("sample", drop=False)
    .sort_index()
)


wildcard_constraints:
    sample="|".join(samples.index),
    read="|".join(["read1", "read2", "readumi"]),


# validate sample sheet and config file
validate(samples, schema="../../config/schemas/samples.schema.yml")
validate(config, schema="../../config/schemas/config.schema.yml")


# helpers
# -----------------------------------------------------
# determine input type, all entries must be either single or paired end
def is_paired_end():
    if samples["read2"].isna().all():
        return False
    elif samples["read2"].notna().all():
        return True
    else:
        msg = (
            "Some samples seem to have a read2 fastq file, while others have only a "
            + "read1 fastq file. \nYou may not mix single-end and paired-end samples."
        )
        logger.error(msg)
        raise ValueError(msg)


# get fastq files
def get_fastq(wildcards):
    file = Path(samples.loc[wildcards["sample"]][wildcards["read"]])
    if file.is_absolute():
        return file
    else:
        input_dir = Path.absolute(Path.cwd())
        return input_dir / file


# get pairs of fastq files for fastp
def get_fastq_pairs(wildcards):
    return expand(
        "results/umi_extract{separate}/{sample}_{read}.fastq.gz",
        separate="_separate" if samples["readumi"].notna().all() else "",
        sample=wildcards.sample,
        read=["read1", "read2"] if is_paired_end() else ["read1"],
    )


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


# returns path to conda envs files
def get_conda_envs_files():
    wf_dir = Path(workflow.basedir).absolute() / "envs"
    try:
        envs = [str(i) for i in wf_dir.iterdir()]
    except FileNotFoundError:
        msg = "No conda environments found in the 'envs' directory."
        logger.error(msg)
    return envs


def get_multiqc_input(wildcards):
    inputs = []
    inputs += expand(
        "results/fastp/{sample}.json",
        sample=samples.index,
    )
    inputs += expand(
        "results/fastqc/{sample}_{read}_fastqc.{ext}",
        sample=samples.index,
        read=["read1", "read2"] if is_paired_end() else ["read1"],
        ext=["html", "zip"],
    )
    inputs += expand(
        "results/mapped/unsorted/{sample}/mapped.bam",
        sample=samples.index,
    )
    inputs += expand(
        "results/deduplicated/log/{sample}_umi_stats.txt",
        sample=samples.index,
    )
    inputs += expand(
        "results/infer_experiment/{sample}.txt",
        sample=samples.index,
    )
    inputs += expand(
        "results/qc/{step}/{sample}.flagstat",
        step=["mapped", "deduplicated"],
        sample=samples.index,
    )
    inputs += expand(
        "results/qc/biotypes/{sample}.counts.summary",
        sample=samples.index,
    )
    inputs += ["results/qc/biotypes/barplot_biotype_data_mqc.json"]
    return inputs


# get final output files
def get_final_output():
    targets = []
    targets.append("results/multiqc/multiqc_report.html")
    targets.append(
        expand(
            "results/{step}/{sample}_cpm_{strand}.bw",
            step=["mapped", "deduplicated"],
            sample=samples.index,
            strand=["plus", "minus"],
        )
    )
    return targets
