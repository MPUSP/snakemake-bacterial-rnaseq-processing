# -----------------------------------------------------
# module to extract selected biotypes from gff file
# -----------------------------------------------------
rule extract_features:
    input:
        gff="results/genome/genome.gff",
    output:
        gff="results/extracted_features/biotypes.gff",
    conda:
        "../envs/extract_features.yml"
    message:
        """--- Extract selected biotype features from genome annotation."""
    params:
        features=config["extract_features"]["biotypes"],
    log:
        path="results/extracted_features/log/extract_features.log",
    script:
        "../scripts/extract_features.py"


# -----------------------------------------------------
# module to generate gtf file from gff
# -----------------------------------------------------
rule gff2gtf:
    input:
        gff="results/extracted_features/biotypes.gff",
    output:
        gtf="results/extracted_features/biotypes.gtf",
    conda:
        "../envs/extract_features.yml"
    message:
        """--- gff to gtf conversion."""
    log:
        path="results/extracted_features/log/gff2gtf.log",
    script:
        "../scripts/gff2gtf.py"


# -----------------------------------------------------
# module to generate gtf file from gff
# -----------------------------------------------------
if is_single_end_experiment:

    rule quantify_biotypes:
        input:
            bam="results/deduplicated/{sample}.bam",
            gtf="results/extracted_features/biotypes.gtf",
            versions="results/qc/versions.txt",
        output:
            counts="results/quantify_biotypes/{sample}.counts",
            summary="results/quantify_biotypes/{sample}.counts.summary",
        conda:
            "../envs/feature_counts.yml"
        message:
            """--- Quantify biotpyes with subread's featureCount."""
        log:
            path="results/quantify_biotypes/log/feature_counts_{sample}.log",
        threads: int(workflow.cores * 0.4) if int(workflow.cores * 0.4) <= 64 else 64  # assign 40% of max cores
        params:
            defaults=config["feature_counts"]["defaults"],
            libtype=config["libtype"],
            tmp=lambda w: f"{w.sample}.tmp",
        shell:
            "if [ {params.libtype} == 'forward' ]; then "
            "libtype=`echo -e '-s 1'`; "
            "else libtype=`echo -e '-s 2'`; "
            "fi; "
            "featureCounts -T {threads} "
            "{params.defaults} "
            "${{libtype}} "
            "-a {input.gtf} "
            "-o {output.counts} "
            "{input.bam} &> {log.path}; "
            "featureCounts -v 2> {params.tmp}; "
            "cat {params.tmp}|head -n 2 | tail -n 1|cut -d\" \" -f2 | sed 's/^/featureCounts,/' | sed 's/v//' >> {input.versions}; "
            "rm -f {params.tmp}"


if is_paired_end_experiment:

    rule quantify_biotypes:
        input:
            bam="results/deduplicated/{sample}.bam",
            gtf="results/extracted_features/biotypes.gtf",
            versions="results/qc/versions.txt",
        output:
            counts="results/quantify_biotypes/{sample}.counts",
            summary="results/quantify_biotypes/{sample}.counts.summary",
        conda:
            "../envs/feature_counts.yml"
        message:
            """--- Quantify biotpyes with subread's featureCount."""
        log:
            path="results/quantify_biotypes/log/feature_counts_{sample}.log",
        threads: int(workflow.cores * 0.4) if int(workflow.cores * 0.4) <= 64 else 64  # assign 40% of max cores
        params:
            defaults=config["feature_counts"]["defaults"],
            libtype=config["libtype"],
            tmp=lambda w: f"{w.sample}.tmp",
        shell:
            "if [ {params.libtype} == 'forward' ]; then "
            "libtype=`echo -e '-s 1'`; "
            "else libtype=`echo -e '-s 2'`; "
            "fi; "
            "featureCounts -T {threads} "
            "{params.defaults} "
            "${{libtype}} "
            "-a {input.gtf} "
            "-p "
            "-o {output.counts} "
            "{input.bam} &> {log.path};"
            "featureCounts -v 2> {params.tmp}; "
            "cat {params.tmp}|head -n 2 | tail -n 1|cut -d\" \" -f2 | sed 's/^/featureCounts,/' | sed 's/v//' >> {input.versions}; "
            "rm -f {params.tmp}"
