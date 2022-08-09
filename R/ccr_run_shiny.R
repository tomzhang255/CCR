#' Launches a user-friendly interface (shiny app) for this package
#'
#' @export
ccr_shiny <- function() {
  appDir <- system.file("shiny-examples", "ccr_shiny", package = "CCR")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `CCR`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
