# Function is run when this package is loaded, i.e., user calls library()
.onLoad <- function(libname, pkgname) {
  # install_miniconda() gives an error if it's already installed
  base::tryCatch({
      reticulate::install_miniconda()
    }, error = function(e) {
      print(e)
    })

  # huggingfaceR requires further dependencies installed to work properly
  huggingfaceR::hf_python_depends()

  # to disable a warning from huggingfaceR
  Sys.setenv(TOKENIZERS_PARALLELISM = FALSE)
}
