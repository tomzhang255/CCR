
<!-- README.md is generated from README.Rmd. Please edit that file -->

# CCR

<!-- badges: start -->
<!-- badges: end -->

The R implementation of CCR (Contextual Concept Representation), a
better version of DDR (Dictionary Distribution Representation) for NLP.

## Installation

You can install the development version of CCR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tomzhang255/CCR")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(CCR)
#> <simpleError: Miniconda is already installed at path "~/Library/r-miniconda-arm64".
#> - Use `reticulate::install_miniconda(force = TRUE)` to overwrite the previous installation.>
#> + '/Users/tomzhang/Library/r-miniconda-arm64/bin/conda' 'install' '--yes' '--name' 'huggingfaceR' '-c' 'conda-forge' 'transformers' 'sentencepiece' 'huggingface_hub' 'datasets' 'sentence-transformers'
res <- ccr_wrapper("data/test.csv", "d", "data/test.csv", "q")
res[ ,! names(res) %in% "embedding"]
#>                          q                           d sim_item_1 sim_item_2
#> 1        Here's a question            Here's an answer  0.7191870  0.4478848
#> 2 This is another question We have yet a second answer  0.3696336  0.4954454
#> 3    A third question here        A third answer there  0.4685105  0.4422214
#>   sim_item_3
#> 1  0.4942263
#> 2  0.4707657
#> 3  0.7367636
```
