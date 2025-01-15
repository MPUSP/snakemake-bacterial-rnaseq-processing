if is_single_end_experiment:

    # -----------------------------------------------------
    # module to trim adapters from reads
    # -----------------------------------------------------
    rule cutadapt:
        input:
            fastq=get_trimming_input,
        output:
            "results/clipped/{sample}.fastq.gz",
        conda:
            "../envs/cutadapt.yml"
        message:
            """--- Trim adapters from reads."""
        params:
            adapter_R1=config["cutadapt"]["read1_adapter"],
            default=config["cutadapt"]["default"],
        log:
            path="results/clipped/log/{sample}.log",
        threads: int(workflow.cores * 0.4)  # assign 40% of max cores
        shell:
            "cutadapt --cores {threads} "
            "-a {params.adapter_R1} "
            "{params.default} "
            "-o {output} "
            "{input.fastq} &> {log.path}"


if is_single_end_experiment and is_rnaseq_nextflex:

    # -----------------------------------------------------
    # module to remove 4nt from 3' end of reads
    # -----------------------------------------------------
    rule truncate_fastq:
        input:
            fastq=get_trunc_input,
        output:
            "results/trunc_fastq/{sample}.fastq.gz",
        conda:
            "../envs/cutadapt.yml"
        message:
            """--- Trim 4nt from 3' end of reads."""
        log:
            path="results/trunc_fastq/log/{sample}.log",
        params:
            default=config["trunc_fastq"]["default"],
        threads: int(workflow.cores * 0.4)  # assign 40% of max cores
        shell:
            "cutadapt --cores {threads} "
            "{params.default} "
            "-o {output} "
            "{input.fastq} &> {log.path}"


if is_paired_end_experiment:

    # -----------------------------------------------------
    # module to trim adapters from paired-end reads
    # -----------------------------------------------------
    rule cutadapt_pe:
        input:
            fastqs=get_trimming_input,
        output:
            R1="results/clipped/{sample}_R1.fastq.gz",
            R2="results/clipped/{sample}_R2.fastq.gz",
        conda:
            "../envs/cutadapt.yml"
        message:
            """--- Trim adapters from reads."""
        log:
            path="results/clipped/log/{sample}.log",
        params:
            adapter_R1=config["cutadapt"]["read1_adapter"],
            adapter_R2=config["cutadapt"]["read2_adapter"],
            default=config["cutadapt"]["default"],
            input_str=lambda w, input: (
                " ".join(input.fastqs) if len(input.fastqs) == 2 else input.fastqs
            ),
        threads: int(workflow.cores * 0.4)  # assign 40% of max cores
        shell:
            "cutadapt --cores {threads} "
            "-a {params.adapter_R1} "
            "-A {params.adapter_R2} "
            "{params.default} "
            "-o {output.R1} -p {output.R2} "
            "{params.input_str} &> {log.path}"


if is_paired_end_experiment and is_rnaseq_nextflex:

    # -----------------------------------------------------
    # module to remove 4nt from 3' end of paired-end reads
    # -----------------------------------------------------
    rule truncate_fastq_pe:
        input:
            fastqs=get_trunc_input,
        output:
            R1="results/trunc_fastq/{sample}_R1.fastq.gz",
            R2="results/trunc_fastq/{sample}_R2.fastq.gz",
        conda:
            "../envs/cutadapt.yml"
        message:
            """--- Trim 4nt from 3' end of reads."""
        log:
            path="results/trunc_fastq/log/{sample}.log",
        params:
            default=config["trunc_fastq"]["default"],
            input_str=lambda w, input: (
                " ".join(input.fastqs) if len(input.fastqs) == 2 else input.fastqs
            ),
        threads: int(workflow.cores * 0.4)  # assign 40% of max cores
        shell:
            "cutadapt --cores {threads} "
            "{params.default} "
            "-o {output.R1} -p {output.R2} "
            "{params.input_str} &> {log.path}"
