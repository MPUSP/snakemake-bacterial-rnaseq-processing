# --------------------------------------------------------------
# module to generate normalized coverage tracks using deeptools
# Note: deeptools implements the strand selection in the counter intuitive way:
# This means, that when using deeptools for extracting coverage files,
# strand must always be switched. forward == reverse!
# --------------------------------------------------------------
rule deeptools_coverage:
    input:
        bam="results/{step}/{sample}.bam",
        bai="results/{step}/{sample}.bam.bai",
    output:
        bw="results/{step}/{sample}_cpm_{strand}.bw",
    threads: int(workflow.cores * 0.25)
    params:
        effective_genome_size=config["deeptools"]["genome_size"],
        extra=lambda wc: (
            config["deeptools"]["extra"]
            + f" --filterRNAstrand {('reverse' if(config['libtype']== 'sense' and wc.strand== 'plus') or(config['libtype']== 'antisense' and wc.strand== 'minus') else 'forward')}"
        ),
    log:
        "results/{step}/{sample}_cpm_{strand}.log",
    message:
        "generate normalized coverage files using deeptools"
    wrapper:
        "v7.0.0/bio/deeptools/bamcoverage"
