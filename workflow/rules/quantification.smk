rule extract_features:
    input:
        gff="results/genome/genome.gff",
    output:
        gff="results/extracted_features/biotypes.gff",
    log:
        path="results/extracted_features/log/extract_features.log",
    conda:
        "../envs/extract_features.yml"
    params:
        gff_source_types=config["get_genome"]["gff_source_type"],
        features=config["extract_features"]["biotypes"],
    message:
        "--- Extract selected biotype features from genome annotation."
    script:
        "../scripts/extract_features.py"


rule gff2gtf:
    input:
        gff="results/extracted_features/biotypes.gff",
    output:
        gtf="results/extracted_features/biotypes.gtf",
    log:
        path="results/extracted_features/log/gff2gtf.log",
    conda:
        "../envs/extract_features.yml"
    message:
        "--- gff to gtf conversion."
    script:
        "../scripts/gff2gtf.py"


rule quantify_biotypes:
    input:
        bam="results/deduplicated/{sample}.bam",
        gtf="results/extracted_features/biotypes.gtf",
    output:
        counts="results/qc/biotypes/{sample}.counts",
        summary="results/qc/biotypes/{sample}.counts.summary",
    log:
        path="results/qc/biotypes/log/{sample}.counts.log",
    conda:
        "../envs/feature_counts.yml"
    threads: max(1, int(workflow.cores * 0.25))
    params:
        defaults=config["feature_counts"]["defaults"],
        libtype=config["libtype"],
        paired="-p --countReadPairs" if is_paired_end() else "",
    message:
        "--- Quantify biotpyes with subread's featureCount."
    shell:
        """
        if [ {params.libtype} == 'sense' ]; then
            libtype=$(echo -e '-s 1')
        else
            libtype=$(echo -e '-s 2')
        fi
        featureCounts -T {threads} \
            {params.defaults} \
            ${{libtype}} \
            -a {input.gtf} \
            {params.paired} \
            -o {output.counts} \
            {input.bam} &>{log.path}
        """


rule merge_counts:
    input:
        counts=expand("results/qc/biotypes/{sample}.counts", sample=samples.index),
        summary=expand(
            "results/qc/biotypes/{sample}.counts.summary", sample=samples.index
        ),
        gtf="results/extracted_features/biotypes.gtf",
    output:
        table="results/quantify_biotypes/all_samples_counts.tsv",
    log:
        path="results/quantify_biotypes/log/merge_counts.log",
    conda:
        "../envs/quantify_biotypes.yml"
    params:
        samples=samples.index,
    message:
        "--- Combine count tables for all samples."
    script:
        "../scripts/merge_counts.py"


rule summarize_biotypes:
    input:
        table="results/quantify_biotypes/all_samples_counts.tsv",
    output:
        tab_counts="results/quantify_biotypes/all_samples_biotype_counts.tsv",
        tab_fractions="results/quantify_biotypes/all_samples_biotype_fraction.tsv",
    log:
        path="results/quantify_biotypes/log/summarize_biotypes.log",
    conda:
        "../envs/quantify_biotypes.yml"
    params:
        samples=samples.index,
    message:
        "--- Extract fraction of biotypes for all samples."
    script:
        "../scripts/summarize_biotypes.py"
