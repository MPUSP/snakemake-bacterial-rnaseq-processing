rule fastqc:
    input:
        fastq="results/get_fastq/{sample}_{read}.fastq.gz",
    output:
        html="results/fastqc/{sample}_{read}_fastqc.html",
        zip="results/fastqc/{sample}_{read}_fastqc.zip",
    params:
        extra=config["fastqc"]["extra"],
    message:
        "--- Checking fastq files with FastQC"
    log:
        "results/fastqc/{sample}.bwa.{read}.log",
    threads: 1
    resources:
        mem_mb=4096,
    wrapper:
        "v6.0.0/bio/fastqc"


rule alignment_stats:
    input:
        "results/{step}/{sample}.bam",
    output:
        "results/qc/{step}/{sample}.flagstat",
    log:
        "results/qc/{step}/{sample}_flagstat.log",
    message:
        "--- Generate mapping statistics of BAM file using samtools."
    threads: int(workflow.cores * 0.2)
    wrapper:
        "v7.5.0/bio/samtools/flagstat"


rule qc_biotype_barplot:
    input:
        table="results/quantify_biotypes/all_samples_biotype_counts.tsv",
        gtf="results/extracted_features/biotypes.gtf",
    output:
        json="results/qc/biotypes/barplot_biotype_data_mqc.json",
    conda:
        "../envs/quantify_biotypes.yml"
    log:
        path="results/qc/biotypes/log/extract_biotype_data.log",
    message:
        """--- Generate multiqc barplot data for biotype distribution."""
    script:
        "../scripts/plot_biotypes.py"


rule get_conda_envs:
    output:
        "results/versions/log_conda_envs.txt",
    conda:
        "../envs/base.yml"
    message:
        """--- Extract software version from conda envs."""
    params:
        conda_files=" ".join(get_conda_envs_files()),
        conda_envs_log=workflow.source_path("../../resources/conda_envs/conda_envs.log"),
    log:
        "results/versions/log/log_envs.log",
    shell:
        "conda env export > {log}; "
        "if [ '{params.conda_files}' == '' ]; then "
        "cat {params.conda_envs_log} > {output}; "
        "else cat {params.conda_files} > {output}; "
        "fi;"


rule get_software_yaml:
    input:
        conda_envs="results/versions/log_conda_envs.txt",
    output:
        yaml="results/versions/rnaseq_preprocessinq_mqc_versions.yml",
        multi_conf="results/multiqc/multiqc_config.yml",
    conda:
        "../envs/base.yml"
    message:
        "--- Generate software version yaml file for MultiQC."
    log:
        path="results/versions/log/yaml_versions.log",
    params:
        config=config["multiqc"]["config"],
    script:
        "../scripts/get_versions.py"


rule multiqc:
    input:
        get_multiqc_input,
        config="results/multiqc/multiqc_config.yml",
    output:
        report="results/multiqc/multiqc_report.html",
    params:
        extra=config["multiqc"]["extra"],
    message:
        "--- Generating MultiQC report for seq data"
    log:
        "results/multiqc/multiqc.log",
    wrapper:
        "v7.5.0/bio/multiqc"
