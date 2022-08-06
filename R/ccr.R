encode_column <- function(model, file_name, col_name) {
  df <- readr::read_csv(file_name, show_col_types = FALSE)
  df <- tidyr::drop_na(df, dplyr::all_of(col_name))
  mat <- model$encode(df[[col_name]])
  df$embedding <- base::split(mat, 1:base::nrow(mat))
  return(df)
}


item_level_ccr <- function(data_encoded_df, questionnaire_encoded_df) {
  d_embeddings <- data_encoded_df$embedding
  q_embeddings <- questionnaire_encoded_df$embedding

  dq <- base::as.data.frame(base::cbind(d_embeddings, q_embeddings))

  sim <- base::sapply(dq$q_embeddings, function(q) {
    base::sapply(dq$d_embeddings, function(d) {
      lsa::cosine(q, d)
    })
  })

  sim <- base::as.data.frame(sim)
  base::names(sim) <- base::paste0("sim_item_", base::names(sim))

  data_encoded_df <- base::cbind(data_encoded_df, sim)
  return(data_encoded_df)
}


#' CCR wrapper function
#'
#' @param data_file Name of the csv file of user-supplied data
#' @param data_col Name of the relevant data column
#' @param q_file Name of the csv file of questionnaire data
#' @param q_col Name of the questionnaire column
#'
#' @return A data frame with similarity score columns appended
#' @export
#'
#' @examples
#' ccr_wrapper("data/test.csv", "d", "data/test.csv", "q")
ccr_wrapper <- function(data_file, data_col, q_file, q_col) {
  model <- huggingfaceR::hf_load_sentence_model("all-MiniLM-L6-v2")

  q_encoded_df <- encode_column(model, q_file, q_col)
  data_encoded_df <- encode_column(model, data_file, data_col)

  ccr_df <- item_level_ccr(data_encoded_df, q_encoded_df)
  # ccr_df <- select(ccr_df, -embeddings)

  # readr::write_csv(ccr_df, "ccr_results.csv")
  return(ccr_df)
}
