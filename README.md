# <a id="anchortitle" />Snakemake workflow: bacterial-rnaseq-processing

![Platform](https://img.shields.io/badge/platform-all-green)
[![Snakemake](https://img.shields.io/badge/snakemake-≥8.0.0-brightgreen.svg)](https://snakemake.github.io)
[![Tests](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/actions/workflows/main.yml/badge.svg)](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/actions/workflows/main.yml)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![workflow catalog](https://img.shields.io/badge/Snakemake%20workflow%20catalog-darkgreen)](https://snakemake.github.io/snakemake-workflow-catalog)

---

A Snakemake workflow for the processing of short read rnaseq data in bacteria.

- [Snakemake workflow: bacterial-rnaseq-processing](#snakemake-workflow-bacterial-rnaseq-processing)
  - [Usage](#usage)
  - [Workflow overview](#workflow-overview)
  - [Deployment options](#deployment-options)
  - [Authors](#authors)
  - [References](#references)

## Usage

The usage of this workflow is described in the [Snakemake Workflow Catalog](https://snakemake.github.io/snakemake-workflow-catalog/docs/workflows/MPUSP/snakemake-bacterial-rnaseq-processing).

Detailed information about input data and workflow configuration can also be found in the [`config/README.md`](config/README.md).

If you use this workflow in a paper, don't forget to give credits to the authors by citing the URL of this repository or its DOI.

## Workflow overview

This workflow is a best-practice workflow for the processing of short read sequencing data in bacteria. The workflow is built using [snakemake](https://snakemake.readthedocs.io/en/stable/) and consists of the following steps:

1. Obtain genome database in `fasta` and `gff` format (`python`, [NCBI Datasets](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/))
   1. Using automatic download from NCBI with a `RefSeq` ID
   2. Using user-supplied files
2. Check quality of input sequencing data ([FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/))
3. Cut adapters and filter by length and/or sequencing quality score ([fastp](https://github.com/OpenGene/fastp))
4. Identify unique molecular identifier (UMI, [UMI-tools](https://umi-tools.readthedocs.io/en/latest/))
5. Map reads to the reference genome ([STAR aligner](https://github.com/alexdobin/STAR))
6. Sort and index aligned rnaseq data ([Samtools](http://www.htslib.org/))
7. Deduplicate reads by unique molecular identifier (UMI, [UMI-tools](https://umi-tools.readthedocs.io/en/latest/))
8. Generate cpm normalized coverage files ([deepTools](https://deeptools.readthedocs.io/en/latest/))
9. Quantify biotype features ([featureCounts](https://subread.sourceforge.net/featureCounts.html))
10. Generate summary report for all processing steps ([MultiQC](https://seqera.io/multiqc/))

---

![](resources/images/dag.png)

<p>Figure 1: Directed acyclic graph (DAG) of the current workflow steps.</p>

## Deployment options

To run the workflow from command line, change the working directory.

```bash
cd path/to/snakemake-workflow-name
```

Adjust options in the default config file `config/config.yml`.
Before running the complete workflow, you can perform a dry run using:

```bash
snakemake --dry-run
```

To run the workflow with test files using **conda**:

```bash
snakemake --cores 2 --sdm conda --directory .test
```

To run the workflow with **apptainer** / **singularity** (not yet supported):

```bash
snakemake --cores 2 --sdm conda apptainer --directory .test
```

## Authors

- Dr Rina Ahmed-Begrich
  - Affiliation: [Max-Planck-Unit for the Science of Pathogens](https://www.mpusp.mpg.de/) (MPUSP), Berlin, Germany
  - ORCID profile: https://orcid.org/0000-0002-0656-1795
- Dr. Michael Jahn
  - Affiliation: [Max-Planck-Unit for the Science of Pathogens](https://www.mpusp.mpg.de/) (MPUSP), Berlin, Germany
  - ORCID profile: https://orcid.org/0000-0002-3913-153X
  - github page: https://github.com/m-jahn

Visit the MPUSP github page at https://github.com/MPUSP for more info on this workflow and other projects.

## References

- Essential tools are linked in the top section of this document
