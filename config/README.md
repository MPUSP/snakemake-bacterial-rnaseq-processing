## Workflow overview

This workflow is a best-practice workflow for the processing of short read sequencing data in bacteria. The workflow is built using [snakemake](https://snakemake.readthedocs.io/en/stable/) and consists of the following steps:

1. Obtain genome database in `fasta` and `gff` format (`python`, [NCBI Datasets](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/))
   1. Using automatic download from NCBI with a `RefSeq` ID
   2. Using user-supplied files
2. Check quality of input sequencing data ([FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
3. Cut adapters and filter by length and/or sequencing quality score ([Cutadapt](https://cutadapt.readthedocs.io/en/stable/))
4. Identify unique molecular identifier (UMI, [UMI-tools](https://umi-tools.readthedocs.io/en/latest/))
5. Map reads to the reference genome ([STAR aligner](https://github.com/alexdobin/STAR))
6. Sort and index aligned rnaseq data ([Samtools](http://www.htslib.org/))
7. Deduplicate reads by unique molecular identifier (UMI, [UMI-tools](https://umi-tools.readthedocs.io/en/latest/))
8. Generate cpm normalized coverage files ([deepTools](https://deeptools.readthedocs.io/en/latest/))
9. Quantify biotype features ([featureCounts](https://subread.sourceforge.net/featureCounts.html))
10. Generate summary report for all processing steps ([MultiQC](https://seqera.io/multiqc/))

## Running the workflow

### Input

#### Reference genome

An NCBI Refseq ID, e.g. `GCF_000006785.2`. Find your genome assembly and corresponding ID on [NCBI genomes](https://www.ncbi.nlm.nih.gov/data-hub/genome/). Alternatively use a custom pair of `*.fasta` file and `*.gff` file that describe the genome of choice.

Important requirements when using custom `*.fasta` and `*.gff` files:

- `*.gff` genome annotation must have the same chromosome/region name as the `*.fasta` file (example: `NC_002737.2`)
- `*.gff` genome annotation must have `gene` and `CDS` type annotation that is automatically parsed to extract transcripts
- all chromosomes/regions in the `*.gff` genome annotation must be present in the `*.fasta` sequence
- but not all sequences in the `*.fasta` file need to have annotated genes in the `*.gff` file

#### Read data

RNA sequencing data in `*.fastq.gz` format. The currently supported input data are **second generation reads**. Input data files are supplied via a mandatory table, whose location is indicated in the `config.yml` file (default: `samples.tsv`). The sample sheet has the following layout:

| sample | condition | replicate | experiment          | fq1               | fq2               | read1 |
| ------ | --------- | --------- | ------------------- | ----------------- | ----------------- | ------ |
| RNA-1  | RNA       | 1         | rnaseq_mpusp_custom | RNA-1_R1.fastq.gz | RNA-1_R2.fastq.gz | \-     |
| RNA-2  | RNA       | 2         | rnaseq_mpusp_custom | RNA-2_R2.fastq.gz | RNA-2_R2.fastq.gz | \-     |

Some configuration parameters of the pipeline may be specific for your data and library preparation protocol. The options should be adjusted in the `config.yml` file.

Currently, we support example configurations for three different sequencing protocols, _i.e._ `rnaseq_nextflex`, `rnaseq_neb_umi`and `rnseq_mpusp_custom`. These example protocols can be found in `resources/protocols/`.

### Output

### Output

| Output File/Folder           | Description                                                              |
| ---------------------------- | ------------------------------------------------------------------------ |
| `results/clipped/`           | Adapter-trimmed and quality-filtered FASTQ files.                        |
| `results/deduplicated/`      | UMI-processed FASTQ/BAM files and UMI statistics.                        |
| `results/genome/`            | Downloaded or user-supplied reference genome and annotation files.       |
| `results/mapped/`            | Aligned reads in BAM format (sorted and indexed).                        |
| `results/qc/`                | Quality control reports for raw and processed reads (FastQC HTML files). |
| `results/deeptools/`         | CPM-normalized coverage files (bigWig format).                           |
| `results/quantify_biotypes/` | Gene/feature count tables (tab-delimited text files).                    |
| `results/report/`            | MultiQC report aggregating QC metrics from all steps.                    |
