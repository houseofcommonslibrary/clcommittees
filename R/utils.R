### Utility functions

#' Cleans the column names of a data frame created from Committees API data
#'
#' @param df A data frame with API variables column names.
#' @param reverse A common column name prefix which should be removed.
#' @keywords internal

clean_column_names <- function(df, remove_prefix) {
    colnames(df) <- df %>%
        janitor::clean_names() %>%
        colnames() %>%
        stringr::str_replace_all(stringr::str_glue("^{remove_prefix}_"), "")
    df
}
