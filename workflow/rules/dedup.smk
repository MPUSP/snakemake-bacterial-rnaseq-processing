rule get_fastq:
    input:
        get_fastq,
    output:
        fastq="results/get_fastq/{sample}_{read}.fastq.gz",
    conda:
        "../envs/base.yml"
    message:
        "obtaining fastq files"
    log:
        "results/get_fastq/{sample}_{read}.log",
    shell:
        "ln -s {input} {output.fastq};"
        "echo 'made symbolic link from {input} to {output.fastq}' > {log}"


rule umi_extract_standard:
    input:
        fq1="results/get_fastq/{sample}_read1.fastq.gz",
        fq2="results/get_fastq/{sample}_read2.fastq.gz" if is_paired_end() else "",
    output:
        fq1="results/umi_extract/{sample}_read1.fastq.gz",
        fq2="results/umi_extract/{sample}_read2.fastq.gz" if is_paired_end() else "",
    conda:
        "../envs/umitools.yml"
    message:
        "--- Extracting UMIs."
    params:
        method=config["umi_extraction"]["method"],
        pattern=config["umi_extraction"]["pattern"],
        read2=(
            lambda wildcards, input, output: (
                f"--read2-in {input.fq2} --read2-out {output.fq2}" if input.fq2 else ""
            )
        ),
    log:
        path="results/umi_extract/log/{sample}.log",
        error="results/umi_extract/log/{sample}.err",
    shell:
        """
        umi_tools extract \
        --extract-method {params.method} \
        {params.pattern} \
        --stdin {input.fq1} \
        --stdout {output.fq1} \
        {params.read2} \
        --log {log.path} 2> {log.error}
        """


# rule umi_extract_separate:
#     input:
#         "results/get_fastq/{sample}_{read}.fastq.gz",
#     output:
#         "results/umi_extract/{sample}_{read}.fastq.gz",
#     conda:
#         "../envs/umitools.yml"
#     log:
#         "results/umi_extract/log/{sample}_{read}.log",
#     message:
#         """--- Extracting UMIs."""
#     script:
#         "../scripts/extract_umis.py"


rule umi_dedup_pe:
    input:
        bam="results/mapped/{sample}.bam",
        bai="results/mapped/{sample}.bam.bai",
    output:
        bam="results/deduplicated/{sample}.bam",
        bai="results/deduplicated/{sample}.bam.bai",
    conda:
        "../envs/umitools.yml"
    message:
        """--- UMI tools deduplication."""
    params:
        tmp="results/deduplicated/sort_{sample}_tmp",
        default=config["umi_dedup"],
    log:
        path="results/deduplicated/log/{sample}.log",
        stderr="results/deduplicated/log/{sample}.stderr",
        stats="results/deduplicated/log/{sample}_umi_stats.txt",
    threads: int(workflow.cores * 0.2)  # assign 25% of max cores.
    shell:
        "umi_tools dedup "
        "--paired "
        "{params.default} "
        "--stdin={input.bam} "
        "--output-stats={log.stats} "
        "--log={log.path} 2> {log.stderr} | "
        "samtools sort -@ {threads} -O bam -T {params.tmp} -o {output.bam}; "
        "samtools index {output.bam}"
