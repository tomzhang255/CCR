## Resubmission

This is a resubmission. In this version I have:

- Updated DESCRIPTION authors and description content.
- Updated NEWS.md to log the resubmission.
- Documented return value for `ccr_setup()` and `ccr_shiny()`.
- Removed `ccr_wrapper()`'s example as the function is simple enough and README.md is sufficient.
- Updated `inst/shiny-examples/ccr_shiny/app.R` so that it no longer modifies `.GlobalEnv`


## R CMD check results

There were no ERRORs, WARNINGs, or NOTEs for macOS R version 4.3.0 Patched (2023-05-18 r84451).

There were no ERRORs or WARNINGs for Windows Server 2022 R-devel 64 bit, only 4 NOTEs:

```
* checking CRAN incoming feasibility ... [11s] NOTE

New submission

Possibly misspelled words in DESCRIPTION:
  CCR (2:43)
  embeddings (8:125)
  pre (8:142)
Maintainer: 'Tom Zhang <zhangsiyuan777@gmail.com>'

* checking examples ... [185s] NOTE
Examples with CPU (user + system) or elapsed time > 5s
          user system elapsed
ccr_setup 1.67   0.39  184.78

* checking for non-standard things in the check directory ... NOTE

* checking for detritus in the temp directory ... NOTE
Found the following files/directories:
  'lastMiKTeXException'
```

- Note 1 can be ignored as the words are indeed correct.
- Note 2 can be ignored as `ccr_setup()` does take a while to run.
- Notes 3 and 4 are harmless and can be ignored.


## Downstream dependencies

There are currently no downstream dependencies for this package.
