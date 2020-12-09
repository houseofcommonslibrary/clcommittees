### Utility functions

#' Removes a repeating prefix from the column names of a data frame
#'
#' @param df A data frame with column names that need cleaning.
#' @param reverse A common column name prefix which should be removed.
#' @keywords internal

remove_column_prefix <- function(df, remove_prefix) {
    colnames(df) <- df %>%
        colnames() %>%
        stringr::str_replace_all(stringr::str_glue("^{remove_prefix}_"), "")
    df
}

#' Formats a vector of numeric ids for inclusion as strings in an API URL
#'
#' @param ids A vector of numeric ids to be formatted
#' @keywords internal

format_ids <- function(ids) {
    format(ids, scientific = FALSE, trim = TRUE)
}
