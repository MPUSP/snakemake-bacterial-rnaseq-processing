# Changelog

## [1.4.0](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/compare/v1.3.0...v1.4.0) (2026-03-12)


### Features

* added schemas, closes [#6](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/issues/6), closes [#7](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/issues/7) ([4be847d](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/4be847d11f2866bd6c17644f5096f34a9225fae6))
* major refactoring of logic and replacement of custom rules with wrappers ([f8b5da4](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/f8b5da4e49e7d6005eb7e8fce79ccc59dfa19ad9))
* split READMEs according to catalog standard ([b5fdbe1](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/b5fdbe16f5753f220aeaa24aa81bc8157ed7c9c7))


### Bug Fixes

* add number of cores to report ([fc38bea](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/fc38beacc3e48a1a12c3e83c66963b8c3a3b0b82))
* added fastp and simplified fastqc input for multiqc ([d516912](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/d516912471bc93d4d3984c69fe66548eda63eec6))
* added names to CI workflows ([ac8ab3c](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/ac8ab3ccf637224f6190ac2abac0ad5b80ab1233))
* adjustr folder structure for logging. ([db5a3e9](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/db5a3e9245fcc0041d01c081967a9125c1e45a81))
* docs to run tests, typo, wrong conf option ([ab591a9](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/ab591a99b0d97e87a6148f24943f25a7caea96de))
* linting on test dir ([861e5fb](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/861e5fb64814bd38ba97a2637a23a7d71e6a3c9d))
* remove style config as it deviates from prettier standard ([ea4a4ea](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/ea4a4ea36cd3fbb8aedf2ffe2d9ac1bd9d54a707))
* removed unused imports, file handle problem and snakemake import in base env ([99c197b](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/99c197ba4cdca6a18f8137dd0551366bc8fe178d))
* replace hard-coded GFF requirements with flexible rules ([e2b75e8](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/e2b75e8a22583f58384fe4264708b45a10e54ff4))
* replaced samtools flagstat with wrapper ([83ebbf5](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/83ebbf5e5eaee1f4ef12fa90d4c33869e8a30e01))
* simplified sample paths, removed unlisting ([e147f05](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/e147f0568bb17bb8433e53dcad7c54b81b466326))
* smarter resource declaration, prevents failurewith few cores ([4fbde14](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/4fbde14005d4930eb10025cda5952e7e2bbaa04c))
* software version for multiqc report. ([74ac88e](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/74ac88eab4bfd3ba75d8653aa050685c2d102be3))
* some fixes to accomodate single-end data and/or no UMIs ([7b12a44](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/7b12a441af0c2564d81a1826dd95c7a2c2a67d5e))
* UMI extraction and dedup for all protocols ([6b9376b](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/6b9376bd00e9499d4d2e843898b196a83835db9b))
* unified all thread defs, enable test run with sufficient threads ([237e17b](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/237e17b30ce293493b36ca8570eff5b15fe6465c))
* update catalog yaml ([e5cfedb](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/e5cfedb18ca74e2a319dc8edc5521bbf38f86971))
* update docs and removing redundancies ([09d3fa5](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/09d3fa5fc154c30933cc9c7f9dd54c603fe166db))
* update for config was missing ([74ca2ca](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/74ca2ca42025afade7ea368571f7b0e984538de8))
* update GH actions wfs ([e38c83f](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/e38c83f6c5f2500bd1ee6a17ab59afa301a07f9a))
* update GH actions. added apptainer functionality. ([1761d67](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/1761d67129baac622e8324a46f302ec1a05ad133))
* update protocol definition configs. ([2605322](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/2605322ecf0a397e070bb713c3c69f65b71d7d5a))
* update umitools to latest version ([78e92d9](https://github.com/MPUSP/snakemake-bacterial-rnaseq-processing/commit/78e92d98b9a16234ffe8aac4caae82ff6e618624))

## [1.3.0](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/compare/v1.2.0...v1.3.0) (2025-01-24)


### Features

* add biotype distribution plot to multiQC report; closes [#5](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/5) ([b29d722](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/b29d722f9ad92ccb0da8b73c305657587a899bbb))
* add module to merge feature count files. Included biotype information; closes [#25](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/25) ([89abb02](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/89abb02b0daf07a1c89f5a2fd8741348d935ccd2))
* added module to summarize biotype distribution. ([e08b53e](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/e08b53e5cf61a6f3c6379083dc0011da507889fc))
* update github actions workflow ([b3e9bb5](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/b3e9bb51f0919fc5ed525645a3d3b501acf2b3fe))
* update github actions workflow. check formatting of yaml files with prettier ([318eca2](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/318eca2ec4252091c1aa286d90c41c33052dce74))


### Bug Fixes

* correct core assignment issue when using featureCounts ([5bc9d36](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/5bc9d362c90fe3a903a1f4c81bbc66fb2ae67b19))
* small updates on github action workflows ([b7248d4](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/b7248d47bd2f0fa2b708e1dbb59aa7b11f683cd2))
* updated conda env log ([d092a53](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/d092a538d57da47871fe78deeebd6432913ec3b8))

## [1.2.0](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/compare/v1.1.3...v1.2.0) (2025-01-15)


### Features

* included module for fastq truncation after trimming for nextflex library kits. fixed various issues when runnning in single-end mode; closes [#22](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/22) ([6558f0b](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/6558f0bd5e869c41c87a960901333e1e5616b63e))


### Bug Fixes

* corrected umi configuration in config for mpusp custom library prep. ([f6e6c51](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/f6e6c51c2122a37d20ee0d589462a314b2f36212))

## [1.1.3](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/compare/v1.1.2...v1.1.3) (2025-01-10)


### Bug Fixes

* change module order in multiqc also in test multiqc_config; closes [#18](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/18) ([92e5a42](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/92e5a422d69877f5da196ed8ae7b5e5890db1d82))
* change module order in multiqc report ([bda4cae](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/bda4cae7bb12a8f10992cb6704d94faae960496c))
* correct libtype and read piar counting parameter when quantifying biotypes; closes [#17](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/17); closes [#19](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/issues/19) ([9413dc0](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/9413dc033c3116db90f0b77abad6d61f515cacd9))

## [1.1.2](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/compare/v1.1.1...v1.1.2) (2025-01-03)


### Bug Fixes

* catch exception in rule 'get_conda_envs' when executing workflow remotely ([0bee102](https://github.com/MPUSP/snakemake-bacterial-rnaseq-preprocessing/commit/0bee1023705212bc4b38a7dee70fbf9a0679e9ba))

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
