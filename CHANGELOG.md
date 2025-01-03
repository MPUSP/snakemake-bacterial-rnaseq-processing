# Changelog

## [1.1.1](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/compare/v1.1.0...v1.1.1) (2025-01-03)


### Bug Fixes

* problem with rerun of dag grpah due to version extraction in sorting rule ([6bb5282](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/6bb5282611b391a39613043d62635cc80385c836))

## [1.1.0](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/compare/v1.0.0...v1.1.0) (2025-01-02)


### Features

* add normalized coverage file output, closes [#8](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/8) ([55b1988](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/55b19880092c219f4da73986764e8d90af5b658a))
* add normalized coverage file output; closes [#8](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/8) ([4c30cbd](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/4c30cbd199c3a127c69b94cf4f5a1f4341081af3))
* added custom software versions in multiqc report, closes [#4](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/4) ([41fbbb2](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/41fbbb20e538c066090a26ad6dcf363f100ab41e))
* reordered multiqc output ([086d855](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/086d855e0f89f15c8c120640170b108dc5a7df0e))


### Bug Fixes

* adjusted parameters for preset experiment config. changed strategy for version logging. ([2297758](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/22977587649e364d5d0ce7d6ec5b00c3670197d0))
* linting issue. no log directive defined. ([37704f5](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/37704f522ca86279bb6776110b5ce93504301fb1))
* super-linter action issue ([8bd5cc9](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/8bd5cc95ba01a3fae63431bf22a03bf6a169e2a0))
* super-linter issue ([926d1cf](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/926d1cfa28932cd6170be7f140550d6f3bfbf666))

## 1.0.0 (2024-12-04)


### Features

* add module to quantify biotypes, closes [#1](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/1) ([9511327](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/95113276aed96a0389ab3212bb7bb6c788a44e2e))


### Bug Fixes

* change resolution of dag ([7520d10](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/7520d10dabbbc609df95732a7ffa82008eb0b361))
* modify samplesheet table to fix linting issue when testing ([ceaaa52](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/ceaaa52452a27408dfa1b2b5f47a834a577b1b09))
