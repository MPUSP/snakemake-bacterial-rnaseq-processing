# -----------------------------------------------------
# module to fetch genome from NCBI or Ensemble
# -----------------------------------------------------
rule get_genome:
    output:
        path=directory("results/genome"),
        fasta="results/genome/genome.fasta",
        gff="results/genome/genome.gff",
    conda:
        "../envs/get_genome.yml"
    message:
        """--- Parsing genome GFF and FASTA files."""
    params:
        database=config["get_genome"]["database"],
        assembly=config["get_genome"]["assembly"],
        fasta=config["get_genome"]["fasta"],
        gff=config["get_genome"]["gff"],
    log:
        path="results/genome/log/get_genome.log",
    script:
        "../scripts/get_genome.py"


# -----------------------------------------------------
# module to map reads to ref genome using STAR aligner
# -----------------------------------------------------
rule create_star_index:
    input:
        genome="results/genome/genome.fasta",
    output:
        path=directory("results/genome/index"),
    conda:
        "../envs/star.yml"
    message:
        """--- STAR index creation."""
    params:
        index=config["star"]["index"],
        indexNbases=config["star"]["genomeSAindexNbases"],
    log:
        path="results/genome/log/star_index.log",
    shell:
        "if [ {params.index} == None ]; then "
        "mkdir {output.path};"
        "STAR --runMode genomeGenerate "
        "--genomeDir {output.path} "
        "--genomeFastaFiles {input.genome} "
        "--genomeSAindexNbases {params.indexNbases} > {log.path}; "
        "rm -f ./Log.out; "
        "else "
        "ln -s {params.index} {output.path}; "
        "echo 'made symbolic link from {params.index} to {output.path}' > {log.path}; "
        "fi;"


# -----------------------------------------------------
# module to map reads to ref genome using STAR aligner
# -----------------------------------------------------
rule star_mapping:
    input:
        fastqs=get_mapping_input,
        genome=rules.create_star_index.output,
    output:
        bam="results/mapped/unsorted/{sample}.bam",
    conda:
        "../envs/star.yml"
    message:
        """--- STAR mapping."""
    params:
        default=config["star"]["default"],
        multi=config["star"]["multi"],
        sam_multi=config["star"]["sam_multi"],
        intron_max=config["star"]["intron_max"],
        outprefix=lambda w, output: f"{os.path.splitext(output.bam)[0]}_",
        input_str=lambda w, input: (
            " ".join(input.fastqs) if len(input.fastqs) == 2 else input.fastqs
        ),
    log:
        "results/mapped/log/{sample}.log",
    threads: int(workflow.cores * 0.2) if int(workflow.cores * 0.2) >= 1 else 1  # assign 20% of max cores.
    shell:
        "STAR "
        "--runThreadN {threads} "
        "--genomeDir {input.genome} "
        "--readFilesIn {params.input_str} "
        "{params.default} "
        "--outFilterMultimapNmax {params.multi} "
        "--alignIntronMax {params.intron_max} "
        "--outSAMmultNmax {params.sam_multi} "
        "--outFileNamePrefix {params.outprefix} "
        "> {output.bam} 2> {log}"


# ---------------------------------------------------
# module to sort and index bam file using samtools
# ---------------------------------------------------
rule mapping_sorted_bam:
    input:
        rules.star_mapping.output.bam,
    output:
        bam="results/mapped/{sample}.bam",
        bai="results/mapped/{sample}.bam.bai",
    conda:
        "../envs/samtools.yml"
    log:
        "results/mapped/log/samtools_{sample}.log",
    message:
        """--- Samtools sort and index bam files."""
    params:
        tmp="results/mapped/sort_{sample}_tmp",
    threads: int(workflow.cores * 0.2)  # assign 20% of max cores
    shell:
        "samtools sort -@ {threads} -O bam -T {params.tmp} -o {output.bam} {input} 2> {log}; "
        "samtools index -@ {threads} {output.bam} 2>> {log}"
