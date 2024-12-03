# ---------------------------------------------------------------
# module to extract umis - umi is located in separate fastq file
# ---------------------------------------------------------------
if is_single_end_experiment and is_rnaseq_neb_umi:

    rule umi_extract:
        input:
            get_umi_input,
        output:
            fastq="results/umi_extract/{sample}.fastq.gz",
        conda:
            "../envs/umitools.yml"
        log:
            path="results/umi_extract/log/{sample}.log",
        message:
            """--- Extracting UMIs."""
        script:
            "../scripts/extract_umis.py"


if is_paired_end_experiment and is_rnaseq_neb_umi:

    rule umi_extract_pe:
        input:
            get_umi_input,
        output:
            R1="results/umi_extract/{sample}_R1.fastq.gz",
            R2="results/umi_extract/{sample}_R2.fastq.gz",
        conda:
            "../envs/umitools.yml"
        log:
            path="results/umi_extract/log/{sample}.log",
        message:
            """--- Extracting UMIs."""
        script:
            "../scripts/extract_umis.py"


# ---------------------------------------------------------------
# module to extract umis - umi is located in read sequence
# ---------------------------------------------------------------
if is_single_end_experiment and (is_rnaseq_mpusp_custom or is_rnaseq_nextflex):

    rule umi_extract:
        input:
            get_umi_input,
        output:
            fastq="results/umi_extraction/{sample}.fastq.gz",
        conda:
            "../envs/umitools.yml"
        message:
            """--- Extracting UMIs."""
        params:
            method=config["umi_extraction"]["method"],
            pattern=config["umi_extraction"]["pattern"],
        log:
            path="results/umi_extract/log/{sample}.log",
            error="results/umi_extract/log/{sample}.err",
        shell:
            "umi_tools extract "
            "--extract-method={params.method} "
            "{params.pattern} "
            "--stdin {input.fastq} "
            "--stdout {output.fastq} "
            "--log={log.path} 2> {log.error}"


if is_paired_end_experiment and is_rnaseq_nextflex:

    rule umi_extract_pe:
        input:
            get_umi_input,
        output:
            R1="results/umi_extract/{sample}_R1.fastq.gz",
            R2="results/umi_extract/{sample}_R2.fastq.gz",
        conda:
            "../envs/umitools.yml"
        message:
            """--- Extracting UMIs."""
        params:
            method=config["umi_extraction"]["method"],
            pattern=config["umi_extraction"]["pattern"],
        log:
            path="results/umi_extract/log/{sample}.log",
            error="results/umi_extract/log/{sample}.err",
        shell:
            "umi_tools extract "
            "--extract-method={params.method} "
            "{params.pattern} "
            "--stdin={input[0]} "
            "--read2-in={input[1]} "
            "--stdout={output.R1} "
            "--read2-out={output.R2} "
            "--log={log.path} 2> {log.error}"


if is_paired_end_experiment and is_rnaseq_mpusp_custom:

    rule umi_extract_pe:
        input:
            get_umi_input,
        output:
            R1="results/umi_extract/{sample}_R1.fastq.gz",
            R2="results/umi_extract/{sample}_R2.fastq.gz",
        conda:
            "../envs/umitools.yml"
        message:
            """--- Extracting UMIs."""
        params:
            method=config["umi_extraction"]["method"],
            pattern=lambda wc: config["umi_extraction"]["pattern"],
        log:
            path="results/umi_extract/log/{sample}.log",
            error="results/umi_extract/log/{sample}.err",
        shell:
            "umi_tools extract "
            "--extract-method={params.method} "
            "--bc-pattern='{params.pattern}' "
            "--stdin={input[0]} "
            "--read2-in={input[1]} "
            "--stdout={output.R1} "
            "--read2-out={output.R2} "
            "--log={log.path} 2> {log.error}"


# ---------------------------------------------
# module to deduplicate reads via UMIs
# ---------------------------------------------
if is_single_end_experiment:

    rule umi_dedup:
        input:
            bam="results/mapped/{sample}.bam",
            bai="results/mapped/{sample}.bai",
        output:
            bam="results/deduplicated/{sample}.bam",
            bai="results/deduplicated/{sample}.bai",
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
            "{params.default} "
            "--stdin={input.bam} "
            "--output-stats={log.stats} "
            "--log={log.path} 2> {log.stderr} | "
            "samtools sort -@ {threads} -O bam -T {params.tmp} -o {output.bam}; "
            "samtools index {output.bam}"


if is_paired_end_experiment:

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
