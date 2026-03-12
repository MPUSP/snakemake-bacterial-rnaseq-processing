rule get_genome:
    input:
        fasta=lambda wildcards: (
            config["get_genome"]["fasta"]
            if config["get_genome"]["database"] == "manual"
            else []
        ),
        gff=lambda wildcards: (
            config["get_genome"]["gff"]
            if config["get_genome"]["database"] == "manual"
            else []
        ),
    output:
        fasta="results/genome/genome.fasta",
        gff="results/genome/genome.gff",
        fai="results/genome/genome.fasta.fai",
    message:
        "--- Parsing genome GFF and FASTA files."
    params:
        database=config["get_genome"]["database"],
        assembly=config["get_genome"]["assembly"],
        gff_source_types=config["get_genome"]["gff_source_type"],
    log:
        "results/genome/get_genome.log",
    wrapper:
        "https://raw.githubusercontent.com/MPUSP/mpusp-snakemake-wrappers/refs/heads/main/get_genome"


rule star_index:
    input:
        fasta=rules.get_genome.output.fasta,
    output:
        directory("results/mapped/index/"),
    threads: 1
    params:
        extra=config["star"]["index"],
    log:
        "results/mapped/index/index.log",
    message:
        "--- Create STAR index."
    wrapper:
        "v7.2.0/bio/star/index"


rule star_mapping:
    input:
        fq1="results/fastp/{sample}_read1.fastq.gz",
        fq2="results/fastp/{sample}_read2.fastq.gz" if is_paired_end() else [],
        idx=rules.star_index.output,
    output:
        aln="results/mapped/unsorted/{sample}/mapped.bam",
        log_final="results/mapped/unsorted/{sample}/Log.final.out",
    log:
        "results/mapped/unsorted/{sample}/star.log",
    message:
        "--- STAR mapping."
    params:
        extra=config["star"]["extra"],
    threads: max(1, int(workflow.cores * 0.25))
    wrapper:
        "v7.2.0/bio/star/align"


rule samtools_sort:
    input:
        "results/mapped/unsorted/{sample}/mapped.bam",
    output:
        "results/mapped/{sample}.bam",
    log:
        "results/mapped/log/{sample}.log",
    message:
        "--- Sort reads after mapping."
    params:
        extra=config["samtools"]["sort"],
    threads: max(1, int(workflow.cores * 0.25))
    wrapper:
        "v7.0.0/bio/samtools/sort"


rule samtools_index:
    input:
        "results/mapped/{sample}.bam",
    output:
        "results/mapped/{sample}.bam.bai",
    log:
        "results/mapped/log/{sample}_index.log",
    message:
        "--- Index reads."
    params:
        extra=config["samtools"]["index"],
    threads: max(1, int(workflow.cores * 0.25))
    wrapper:
        "v7.0.0/bio/samtools/index"
