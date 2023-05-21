#' Launches a user-friendly interface (shiny app) for this package
#'
#' @return No return value, called for side effects.
#'
#' @export
ccr_shiny <- function() {
  appDir <- system.file("shiny-examples", "ccr_shiny", package = "CCR")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `CCR`.", call. = FALSE)
  }

  # the actual usage of these dependencies are in inst/shiny-examples/ccr_shiny/app.R
  # mentioned here simply to suppress check() notes
  foo <- shinyjs::useShinyjs()
  foo <- shinydashboard::dashboardBody()
  foo <- rhandsontable::rHandsontableOutput("foo")

  shiny::runApp(appDir, display.mode = "normal")
}
