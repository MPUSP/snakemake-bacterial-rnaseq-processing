# --------------------------------------------------------------
# module to generate normalized coverage tracks using deeptools
# Note: deeptools implements the strand selection in the counter intuitive way:
# This means, that when using deeptools for extracting coverage files,
# strand must always be switched. forward == reverse!
# --------------------------------------------------------------
rule normalize_bw:
    input:
        get_bigwig_input,
    output:
        "results/{step}/wig_normalized/{sample}_cpm_{strand}.bw",
    conda:
        "../envs/deeptools.yml"
    message:
        """--- Generate normalized bigwig coverage file."""
    log:
        log="results/{step}/wig_normalized/log/{sample}_cpm_{strand}.log",
        stderr="results/{step}/wig_normalized/log/{sample}_cpm_{strand}.stderr",
    params:
        bin=lambda wc: config["deeptools"]["bin_size"],
        norm=lambda wc: config["deeptools"]["normalize"],
        defaults=lambda wc: (
            " ".join(
                [config["deeptools"]["defaults"], config["deeptools"]["paired_end"]]
            )
            if is_paired_end_experiment
            else config["deeptools"]["defaults"]
        ),
        libtype=lambda wc: config["libtype"],
        strand=lambda wc: wc.strand,
    threads: int(workflow.cores * 0.2)  # assign 20% of max cores
    shell:
        "if [ {params.libtype} == 'sense' ] && [ {params.strand} == 'plus' ]; then "
        "strand=`echo -e 'reverse'`; "
        "elif [ {params.libtype} == 'antisense' ] && [ {params.strand} == 'plus' ]; then "
        "strand=`echo -e 'forward'`; "
        "elif [ {params.libtype} == 'sense' ] && [ {params.strand} == 'minus' ]; then "
        "strand=`echo -e 'forward'`; "
        "else strand=`echo -e 'reverse'`; "
        "fi; "
        "bamCoverage --bam {input} "
        "--binSize {params.bin} "
        "--normalizeUsing {params.norm} "
        "--outFileFormat bigwig "
        "-p {threads} "
        "{params.defaults} "
        "--filterRNAstrand ${{strand}} "
        "-o {output} > {log.log} 2> {log.stderr}"
