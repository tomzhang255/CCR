# Function is run when this package is loaded, i.e., user calls library()
.onLoad <- function(libname, pkgname) {
  # install_miniconda() gives an error if it's already installed
  tryCatch({
      print("Checking installation of dependency: miniconda...")
      reticulate::install_miniconda()
    }, error = function(e) {
      print(e)  # print, not stop
    })

  # the convention is to include Imports: huggingfaceR and Remotes: farach/huggingfaceR in DESCRIPTION
  # however, loading huggingfaceR requires miniconda, so we have to execute install_miniconda()
  # before huggingfaceR loads from DESCRIPTION
  # r documentation does not provide an official solution to this, but this is a temporary workaround
  print("Updating devtools...")
  install.packages("devtools", repos = "http://cran.us.r-project.org")
  print("Checking installation of dependency: huggingfaceR...")
  devtools::install_github("farach/huggingfaceR")
  library(huggingfaceR)

  # huggingfaceR requires further dependencies installed to work properly
  print("Checking installation of huggingfaceR dependencies...")
  huggingfaceR::hf_python_depends()

  # to disable a warning from huggingfaceR
  Sys.setenv(TOKENIZERS_PARALLELISM = FALSE)
}
