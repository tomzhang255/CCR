#' Call this function when it's your first time installing this package.
#' This will set up the miniconda environment for python,
#' which is how this R package works under the hood.
#'
#' @export
ccr_setup <- function() {
  # install miniconda
  base::tryCatch({
    reticulate::install_miniconda()
  }, error = function(e) {
    # install_miniconda() gives an error if it's already installed, we will simply move on
    if (stringr::str_detect(e$message, "Miniconda is already installed")) {
      base::invisible()
    } else {
      stop(e$message)  # in case installation failed
    }
  })

  # setup CCR's conda environment
  ccr_env <- Sys.getenv("CCR_ENV")

  if (ccr_env == "") {
    ccr_env <- "CCR"
  }

  # try to activate CCR's conda env, mainly to test if it exists
  res <-
    tryCatch({
      reticulate::use_miniconda(ccr_env, required = TRUE)
    }, error = function(e) {
      e
    })

  # if CCR's environment does not exist, we create it now
  if ("error" %in% class(res)) {
    if (stringr::str_detect(res$message, "Unable to locate conda environment")) {
      packageStartupMessage("\nCreating miniconda environment CCR\n")
      reticulate::conda_create(envname = ccr_env,
                               conda = paste0(reticulate::miniconda_path(), "/condabin/conda"))
      packageStartupMessage("\nSuccessfully created miniconda environment CCR\n")
    }
    # current r sessino already has a python instance running - need to restart
    if (stringr::str_detect(res$message, "failed to initialize requested version of Python")) {
      stop("A version of python outside of the CCR conda environment has already been initialized. Please restart the current R session and re-run `ccr_setup()`")
    }
  }

  # activate this conda env
  python_path <-
    dplyr::pull(dplyr::filter(reticulate::conda_list(), .data[["name"]] == ccr_env), .data[["python"]])

  Sys.setenv(RETICULATE_PYTHON = python_path)

  reticulate::use_condaenv(condaenv = ccr_env, required = TRUE)

  # install python dependencies in this conda env
  base::tryCatch({
    packageStartupMessage("\nInstalling python dependencies in conda environment CCR\n")
    reticulate::conda_install(ccr_env,
                              packages = c("transformers", "sentencepiece", "huggingface_hub",
                                           "datasets", "sentence-transformers"))
    packageStartupMessage("\nSuccessfully installed python dependencies\n")
  },
  # message = function(m) {
  #   if (stringr::str_detect(m$message, "All requested packages already installed")) {
  #     base::invisible()
  #   }
  # },
  warning = function(w) {
    if (stringr::str_detect(w$message, "A newer version of conda exists")) {
      base::invisible()  # suppress: a new version of conda exists, but it's unnecessary to update it
    }
  })

  # to disable a warning from transformers
  base::Sys.setenv(TOKENIZERS_PARALLELISM = FALSE)

  invisible()
}
