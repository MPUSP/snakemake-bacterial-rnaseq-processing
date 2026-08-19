
rule gffread_gff:
    input:
        fasta="results/genome/genome.fasta",
        annotation="results/genome/genome.gff",
    output:
        records="results/genome/genome.bed",
    log:
        "results/genome/gffread.log",
    threads: 1
    params:
        extra=config["infer_experiment"]["gffread"]["extra"],
    message:
        "convert genome annotation from GFF to BED format"
    wrapper:
        "v9.6.0/bio/gffread"


rule rseqc_infer_experiment:
    input:
        aln="results/mapped/{sample}.bam",
        refgene="results/genome/genome.bed",
    output:
        "results/infer_experiment/{sample}.txt",
    log:
        "results/infer_experiment/{sample}.log",
    params:
        extra=config["infer_experiment"]["rseqc"]["extra"],
    message:
        "infer experiment type from mapping to features"
    wrapper:
        "v9.16.0/bio/rseqc/infer_experiment"


rule deeptools_coverage:
    input:
        bam="results/{step}/{sample}.bam",
        bai="results/{step}/{sample}.bam.bai",
    output:
        bw="results/{step}/{sample}_cpm_{strand}.bw",
    log:
        "results/{step}/log/{sample}_cpm_{strand}.log",
    threads: max(1, int(workflow.cores * 0.25))
    params:
        effective_genome_size=config["deeptools"]["genome_size"],
        extra=lambda wc: (
            config["deeptools"]["extra"]
            + f" --filterRNAstrand {('reverse' if(config['libtype']== 'sense' and wc.strand== 'plus') or(config['libtype']== 'antisense' and wc.strand== 'minus') else 'forward')}"
        ),
    message:
        "generate normalized coverage files using deeptools"
    wrapper:
        "v7.0.0/bio/deeptools/bamcoverage"
