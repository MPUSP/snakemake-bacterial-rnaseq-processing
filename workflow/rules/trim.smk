# -----------------------------------------------------
# module to trim adapters from reads
# -----------------------------------------------------
if is_single_end_experiment:

    rule cutadapt:
        input:
            get_trimming_input,
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
            "{input[0]} &> {log.path}"


if is_paired_end_experiment:

    rule cutadapt_pe:
        input:
            get_trimming_input,
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
        threads: int(workflow.cores * 0.4)  # assign 40% of max cores
        shell:
            "cutadapt --cores {threads} "
            "-a {params.adapter_R1} "
            "-A {params.adapter_R2} "
            "{params.default} "
            "-o {output.R1} -p {output.R2} "
            "{input[0]} {input[1]} &> {log.path}"


# NOTE: for rnaseq_nextflex mode after clipping, 4 nt need to be removed from the 3p end -> use cutadapt -u='-4' -U='-4'
