# Helper functions for ccr_wrapper()

encode_column <- function(model, file_name, col_name) {
  df <- readr::read_csv(file_name, show_col_types = FALSE)

  # check if col_name exists in df
  if (!col_name %in% names(df)) {
    stop(paste0("Column ", col_name, " does not exist in ", file_name))
  }

  # coerce col to string
  tryCatch({
    df[[col_name]] <- as.character(df[[col_name]])
  }, error = function(e) {
    stop(paste0("Failed to coerce column ", col_name, " from ", file_name, " to type string"))
  })

  # make sure column values are not too short
  nrow_old <- nrow(df)
  df <- dplyr::filter(df, nchar(.data[[col_name]]) >= 5)
  df <- tidyr::drop_na(df, dplyr::all_of(col_name))
  nrow_new <- nrow(df)

  # issue message if values are dropped
  if (nrow_new < nrow_old) {
    warning(paste0("Values in column ", col_name, " should be at least 5 characters long. ",
                         nrow_old - nrow_new, " rows have been dropped; ",
                         "these may be short sentences or NA's"))
  }

  # check length
  if (nrow_new < 1) {
    stop(paste0("No rows left after cleaning column ", col_name, " in ", file_name))
  }

  # make embedding
  mat <- model$encode(df[[col_name]])

  # corner case - df has 1 row
  if (nrow_new == 1) {
    mat <- t(mat)
  }

  df$embedding <- split(mat, 1:nrow(mat))
  return(df)
}


item_level_ccr <- function(data_encoded_df, questionnaire_encoded_df) {
  d_embeddings <- data_encoded_df$embedding
  q_embeddings <- questionnaire_encoded_df$embedding

  # calculate cosine similarity
  sim <- sapply(d_embeddings, function(d) {
    sapply(q_embeddings, function(q) {
      lsa::cosine(d, q)
    })
  })

  # corner case - one of the columns is length 1
  if (!is.null(dim(sim))) {
    sim <- t(sim)
  }

  sim <- as.data.frame(sim)

  # prettify column names
  if (length(names(sim)) > 1) {
    names(sim) <- paste0("sim_item_", names(sim))
  } else {
    names(sim) <- "sim_item_1"
  }

  data_encoded_df <- cbind(data_encoded_df, sim)
  return(data_encoded_df)
}


#' CCR wrapper function
#'
#' @param data_file Name of the csv file of user-supplied data
#' @param data_col Name of the relevant data column
#' @param q_file Name of the csv file of questionnaire data
#' @param q_col Name of the questionnaire column
#' @param model Name of a huggingface model (https://huggingface.co/models); "all-MiniLM-L6-v2" by default
#'
#' @return A data frame with similarity score columns appended
#' @export
#'
#' @examples
#' ccr_wrapper("data/test.csv", "d", "data/test.csv", "q")
ccr_wrapper <- function(data_file, data_col, q_file, q_col, model = "all-MiniLM-L6-v2") {
  # basic argument validation - data types
  stopifnot(is.character(data_file),
                  is.character(data_col),
                  is.character(q_file),
                  is.character(q_col),
                  is.character(model))

  # validate model name
  tryCatch({
    model <- huggingfaceR::hf_load_sentence_model(model)
  }, error = function(e) {
    stop(paste0("Loading model ", model,
                " failed. Make sure it exists on https://huggingface.co/models"))
  })

  q_encoded_df <- encode_column(model, q_file, q_col)
  data_encoded_df <- encode_column(model, data_file, data_col)

  ccr_df <- item_level_ccr(data_encoded_df, q_encoded_df)
  # ccr_df <- select(ccr_df, -embeddings)

  # readr::write_csv(ccr_df, "ccr_results.csv")
  return(ccr_df)
}
