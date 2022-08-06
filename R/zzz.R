# Function is run when this package is loaded, i.e., user calls library()
.onLoad <- function(libname, pkgname) {
  # install_miniconda() gives an error if it's already installed
  base::tryCatch({
      reticulate::install_miniconda()
    }, error = function(e) {
      print(e)
    })

  # the convention is to include Imports: huggingfaceR and Remotes: farach/huggingfaceR in DESCRIPTION
  # however, loading huggingfaceR requires miniconda, so we have to execute install_miniconda()
  # before huggingfaceR loads from DESCRIPTION
  # r documentation does not provide an official solution to this, but this is a temporary workaround
  install.packages("devtools", repos = "http://cran.us.r-project.org")
  devtools::install_github("farach/huggingfaceR")
  library(huggingfaceR)

  # huggingfaceR requires further dependencies installed to work properly
  huggingfaceR::hf_python_depends()

  # to disable a warning from huggingfaceR
  Sys.setenv(TOKENIZERS_PARALLELISM = FALSE)
}
