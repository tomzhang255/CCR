library(tidyverse)
library(reticulate)
# install_miniconda()
# install.packages("devtools")
# library(huggingfaceR)  # seems to require miniconda
# hf_python_depends()
library(lsa)
library(readxl)
library(cld3)


# Helper function for encode_column()

# check length of questionnaire items [issue error if 1 word; issue warning if 2 or 3 words]
# check length of text [issue warning if fewer than 4 words]
# returns new df - possibly with fewer rows
validate_col_item_length <- function(df, file_name, col_name, col_type) {
  col_item_lengths <- sapply(stringr::str_split(df[[col_name]], "\\s+"),
                             function(x) {length(x)})

  if (col_type == "q") {
    # questionnaire item is legnth 1
    nrow_old <- nrow(df)
    df <- dplyr::filter(df, col_item_lengths > 1)
    nrow_new <- nrow(df)
    if (nrow_new < nrow_old) {
      warning(paste0(nrow_old - nrow_new, " rows from column ", col_name, " in ", file_name,
                     " contain only 1 word. These rows have been dropped. Row indices: "),
              paste0(which(col_item_lengths == 1), collapse = ", "),
              paste0("\n"))
    }

    # questionnaire item is legnth 2 or 3
    len_two_three_idx <- which(col_item_lengths %in% c(2, 3))
    if (length(len_two_three_idx) > 0) {
      warning(paste0(length(len_two_three_idx), " rows from column ", col_name, " in ", file_name,
                     " have only 2 or 3 words. Row indices: "),
              paste0(len_two_three_idx, collapse = ", "),
              paste0("\n"))
    }

  } else if (col_type == "d") {
    # user data text < 4 words
    len_four_less_idx <- which(col_item_lengths < 4)
    if (length(len_four_less_idx > 0)) {
      warning(paste0(length(len_four_less_idx), " rows from column ", col_name, " in ", file_name,
                     " have less than 4 words. Row indices: "),
              paste0(len_four_less_idx, collapse = ", "),
              paste0("\n"))
    }
  }

  return(df)
}


# Helper functions for ccr_wrapper()

encode_column <- function(model, df, file_name, col_name, col_type) {
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

  # check language in col
  col_langs <- unique(cld3::detect_language(tidyr::drop_na(df, dplyr::all_of(col_name))[[col_name]]))

  if (length(col_langs) > 1 | !"en" %in% col_langs) {
    warning(paste0(paste0("Non-English language detected in column ", col_name, " from ", file_name,
                          " . Languages detected by cld3: "),
                   paste0(col_langs, collapse = ", "),
                   paste0("\n")))
  }

  # drop NA's, issue warning if dropped any
  nrow_old <- nrow(df)
  df <- tidyr::drop_na(df, dplyr::all_of(col_name))
  nrow_new <- nrow(df)

  if (nrow_new < nrow_old) {
    warning(paste0(nrow_old - nrow_new, " NA's have been dropped from column ", col_name,
                   " in ", file_name),
            paste0("\n"))
  }

  # check length of column items
  df <- validate_col_item_length(df, file_name, col_name, col_type)
  
  # check row count
  if (nrow(df) < 1) {
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
ccr_wrapper <- function(data_df, data_file, data_col, q_df, q_file, q_col, model = "all-MiniLM-L6-v2") {
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

  q_encoded_df <- encode_column(model, q_df, q_file, q_col, "q")
  data_encoded_df <- encode_column(model, data_df, data_file, data_col, "d")

  ccr_df <- item_level_ccr(data_encoded_df, q_encoded_df)
  ccr_df <- dplyr::select(ccr_df, -embedding)  # drop embedding col for aesthetic reasons

  # readr::write_csv(ccr_df, "ccr_results.csv")
  return(ccr_df)
}
