# Function is run when this package is loaded, i.e., user calls library()
.onLoad <- function(libname, pkgname) {
  # install_miniconda() gives an error if it's already installed
  base::tryCatch({
    # print("Checking installation of dependency: miniconda...")
    reticulate::install_miniconda()
  }, error = function(e) {
    base::invisible()  # we will simply move on, because miniconda is already installed
  })

  # the convention is to include Imports: huggingfaceR and Remotes: farach/huggingfaceR in DESCRIPTION
  # however, loading huggingfaceR requires miniconda, so we have to execute install_miniconda()
  # before huggingfaceR loads from DESCRIPTION
  # r documentation does not provide an official solution to this, but this is a temporary workaround
  # print("Updating devtools...")
  base::tryCatch({
    utils::install.packages("devtools", repos = "http://cran.us.r-project.org")
  }, message = function(m) {
    base::invisible()  # suppress message when devtools is already installed
  })

  # print("Checking installation of dependency: huggingfaceR...")
  base::tryCatch({
    devtools::install_github("farach/huggingfaceR")
    # library(huggingfaceR)
  }, message = function(m) {
    base::invisible()  # suppress message when huggingfaceR is already installed
  })

  # huggingfaceR requires further dependencies installed to work properly
  # print("Checking installation of huggingfaceR dependencies...")
  base::tryCatch({
    huggingfaceR::hf_python_depends()
  },

  message = function(m) {
    base::invisible()  # suppress message when dependencies are already installed
  }, warning = function(w) {
    base::invisible()  # will warn: a new version of conda exists, but it's unnecessary to update it
  })

  # to disable a warning from huggingfaceR
  base::Sys.setenv(TOKENIZERS_PARALLELISM = FALSE)
}
