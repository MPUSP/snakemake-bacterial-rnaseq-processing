rule fastp:
    input:
        sample=get_fastq_pairs,
    output:
        html="results/fastp/{sample}.html",
        json="results/fastp/{sample}.json",
        trimmed=expand(
            "results/fastp/{{sample}}_{read}.fastq.gz",
            read=["read1", "read2"] if is_paired_end() else ["read1"],
        ),
    log:
        "results/fastp/{sample}.log",
    message:
        "trimming and QC filtering reads using fastp"
    params:
        extra=config["fastp"]["extra"],
    threads: max(1, int(workflow.cores * 0.25))
    resources:
        mem_mb=4096,
    wrapper:
        "v7.0.0/bio/fastp"
