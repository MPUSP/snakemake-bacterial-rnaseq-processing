# -----------------------------------------------------
# modules to make fastqc report
# -----------------------------------------------------
if is_single_end_experiment:

    rule fastqc:
        input:
            fastq=get_qc_input,
        output:
            report=directory("results/qc/{status}_reads/{sample}"),
        conda:
            "../envs/fastqc.yml"
        message:
            """--- Checking fastq files with FastQC."""
        log:
            "results/qc/{status}_reads/log/{sample}.log",
        threads: int(workflow.cores * 0.2)  # assign 20% of max cores
        shell:
            "mkdir -p {output.report}; "
            "fastqc --nogroup --threads {threads} -o {output.report} -q {input.fastq} > {log}"


if is_paired_end_experiment:

    rule fastqc:
        input:
            fastqs=get_qc_input,
        output:
            report=directory("results/qc/{status}_reads/{sample}"),
        conda:
            "../envs/fastqc.yml"
        message:
            """--- Checking fastq files with FastQC."""
        log:
            "results/qc/{status}_reads/log/{sample}.log",
        threads: int(workflow.cores * 0.2)  # assign 20% of max cores
        shell:
            "mkdir -p {output.report}; "
            "fastqc --nogroup --threads {threads} -o {output.report} -q {input.fastqs[0]} > {log}; "
            "fastqc --nogroup --threads {threads} -o {output.report} -q {input.fastqs[1]} &> {log}"


# -----------------------------------------------------
# module to determine alignment stats
# -----------------------------------------------------
rule alignment_stats:
    input:
        stats=get_stats_input,
    output:
        "results/qc/{step}_alignment/{sample}.flagstat",
    conda:
        "../envs/samtools.yml"
    log:
        "results/qc/{step}_alignment/log/samtools_{sample}.log",
    message:
        """--- Generate mapping statistics of BAM file using samtools."""
    threads: int(workflow.cores * 0.2)  # assign 20% of max cores
    shell:
        "samtools flagstat -@ {threads} {input.stats} > {output} 2> {log}"


# -----------------------------------------------------
# module to qc quantified biotypes
# -----------------------------------------------------
rule qc_biotypes:
    input:
        "results/quantify_biotypes/{sample}.counts.summary",
    output:
        "results/qc/biotypes/{sample}.counts.summary",
    conda:
        "../envs/feature_counts.yml"
    log:
        "results/qc/biotypes/log/copy_{sample}.log",
    message:
        """--- Copy biotype quantification summary."""
    shell:
        "cp {input} {output} &> {log}"


# -----------------------------------------------------
# module to extract software versions from conda envs
# -----------------------------------------------------
rule get_conda_envs:
    output:
        "results/versions/log_conda_envs.txt",
    conda:
        "../envs/base.yml"
    message:
        """--- Extract software version from conda envs."""
    params:
        conda_files=get_conda_envs_files(),
    log:
        "results/versions/log/log_envs.log",
    shell:
        "conda env export > {log}; "
        "cat {params.conda_files} >> {output}"


# -----------------------------------------------------
# module to generate software version yaml file MultiQC
# -----------------------------------------------------
rule get_software_yaml:
    input:
        conda_envs="results/versions/log_conda_envs.txt",
    output:
        yaml="results/versions/rnaseq_preprocessinq_mqc_versions.yml",
        multi_conf="results/qc/multiqc/multiqc_config.yml",
    conda:
        "../envs/base.yml"
    message:
        """--- Generate software version yaml file for MultiQC."""
    log:
        path="results/versions/log/yaml_versions.log",
    params:
        config=config["multiqc"]["config"],
    script:
        "../scripts/get_versions.py"


# -----------------------------------------------------
# module to run multiQC on input + processed files
# -----------------------------------------------------
rule multiqc:
    input:
        construct_multiqc_input(),
        config="results/qc/multiqc/multiqc_config.yml",
    output:
        report="results/qc/multiqc/multiqc_report.html",
        final="results/report/multiqc_report.html",
    conda:
        "../envs/multiqc.yml"
    message:
        """--- Generating MultiQC report for seq data."""
    log:
        path="results/qc/multiqc/log/multiqc.log",
    params:
        defaults=config["multiqc"]["defaults"],
        outdir=lambda w, output: os.path.split(output.report)[0],
        filename=lambda w, output: os.path.split(output.report)[1],
        qc_dirs=define_multiqc_dirs(),
    shell:
        "multiqc {params.defaults} "
        "--config {input.config} "
        "--outdir {params.outdir} "
        "--filename {params.filename} "
        "--dirs {params.qc_dirs} &> {log.path}; "
        "cp {output.report} {output.final}"
