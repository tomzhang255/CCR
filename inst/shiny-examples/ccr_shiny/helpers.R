library(readr)
library(readxl)


validate_file <- function(input_file) {
  ext <- tools::file_ext(input_file$datapath)
  validate(need(ext %in% c("csv", "xls", "xlsx"), "\tPlease upload a csv or excel file"))
  return(ext)
}


render_select_col_ui <- function(input_file, id, label, values, value_id) {
  ext <- validate_file(input_file)

  if (ext == "csv") {
    data <- read_csv(input_file$datapath)
  } else {
    data <- read_excel(input_file$datapath)
  }

  values[[value_id]] <- data
  cols <- names(data)
  selectInput(id, label = label, choices = cols)
}


render_hot <- function(df, col_to_highlight) {
  if (!is.null(df)) {
    rhandsontable(df, height = 100,
                  col_highlight = which(names(df) == col_to_highlight) - 1) %>%
      hot_cols(renderer = "
        function(instance, td, row, col, prop, value, cellProperties) {
          Handsontable.renderers.NumericRenderer.apply(this, arguments);

          if (instance.params) {
            hcols = instance.params.col_highlight;
            hcols = hcols instanceof Array ? hcols : [hcols];
          }

          if (instance.params && hcols.includes(col)) {
            td.style.background = 'lightgreen';
          }
        }")
  }
}
