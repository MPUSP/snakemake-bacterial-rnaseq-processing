rule extract_features:
    input:
        gff="results/genome/genome.gff",
    output:
        gff="results/extracted_features/biotypes.gff",
    conda:
        "../envs/extract_features.yml"
    message:
        "--- Extract selected biotype features from genome annotation."
    params:
        gff_source_types=config["get_genome"]["gff_source_type"],
        features=config["extract_features"]["biotypes"],
    log:
        path="results/extracted_features/log/extract_features.log",
    script:
        "../scripts/extract_features.py"


rule gff2gtf:
    input:
        gff="results/extracted_features/biotypes.gff",
    output:
        gtf="results/extracted_features/biotypes.gtf",
    conda:
        "../envs/extract_features.yml"
    message:
        "--- gff to gtf conversion."
    log:
        path="results/extracted_features/log/gff2gtf.log",
    script:
        "../scripts/gff2gtf.py"


rule quantify_biotypes:
    input:
        bam="results/deduplicated/{sample}.bam",
        gtf="results/extracted_features/biotypes.gtf",
    output:
        counts="results/qc/biotypes/{sample}.counts",
        summary="results/qc/biotypes/{sample}.counts.summary",
    conda:
        "../envs/feature_counts.yml"
    message:
        "--- Quantify biotpyes with subread's featureCount."
    log:
        path="results/qc/biotypes/log/{sample}.counts.log",
    threads: max(1, int(workflow.cores * 0.25))
    params:
        defaults=config["feature_counts"]["defaults"],
        libtype=config["libtype"],
        paired="-p --countReadPairs" if is_paired_end() else "",
    shell:
        """
        if [ {params.libtype} == 'sense' ]; then
            libtype=`echo -e '-s 1'`;
        else
            libtype=`echo -e '-s 2'`;
        fi;
        featureCounts -T {threads} \
        {params.defaults} \
        ${{libtype}} \
        -a {input.gtf} \
        {params.paired} \
        -o {output.counts} \
        {input.bam} &> {log.path}
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
    conda:
        "../envs/quantify_biotypes.yml"
    message:
        "--- Combine count tables for all samples."
    log:
        path="results/quantify_biotypes/log/merge_counts.log",
    params:
        samples=samples.index,
    script:
        "../scripts/merge_counts.py"


rule summarize_biotypes:
    input:
        table="results/quantify_biotypes/all_samples_counts.tsv",
    output:
        tab_counts="results/quantify_biotypes/all_samples_biotype_counts.tsv",
        tab_fractions="results/quantify_biotypes/all_samples_biotype_fraction.tsv",
    conda:
        "../envs/quantify_biotypes.yml"
    message:
        "--- Extract fraction of biotypes for all samples."
    log:
        path="results/quantify_biotypes/log/summarize_biotypes.log",
    params:
        samples=samples.index,
    script:
        "../scripts/summarize_biotypes.py"
