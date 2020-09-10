### Functions for fetching data from the committees endpoint

#' Fetch data on all committees as a tibble
#'
#' \code{fetch_committees} fetches data on all committees and returns it as a
#' tibble containing one row per committee.
#'
#' By default this function returns a subset of the columns and ignores any
#' nested and redundant columns. Set \code{summary = FALSE} when calling the
#' function to retrieve the full data.
#'
#' @param current A boolean indicating whether to return only the committees
#'   without an end date. The default is FALSE.
#' @param summary A boolean indicating whether to return the summary columns or
#'   the the full table. The default is TRUE.
#' @export

fetch_committees <- function(
    current = FALSE,
    summary = TRUE) {

    # Get data for all committees
    url <- stringr::str_c(
        "https://committees-api.parliament.uk/committees?",
        "parameters.all=true&",
        "parameters.currentOnly=false")

    df <- request_items(url) %>%
        # Rename the id column to be informative
        dplyr::rename(committee_id = .data$id)

    # Convert date columns to Date
    df$start_date <- as.Date(df$start_date)
    df$end_date <- as.Date(df$end_date)
    df$date_commons_appointed <- as.Date(df$date_commons_appointed)
    df$date_lords_appointed <- as.Date(df$date_lords_appointed)

    # Select only a subset of columns if requested
    if (summary == TRUE) {
        df <- df %>% dplyr::select(
            .data$committee_id,
            .data$name,
            .data$start_date,
            .data$end_date,
            .data$is_commons,
            .data$is_lords,
            .data$email,
            .data$phone,
            .data$category_id,
            .data$category_name)
    }

    # Remove old committees if requested
    if (current == TRUE) {
        df <- df %>% dplyr::filter(is.na(.data$end_date))
    }

    df
}

#' Fetch data on the subcommittees of parent committees as a tibble
#'
#' \code{fetch_sub_committees} fetches data on the subcommittees of parent
#' comittees and returns it as a tibble containing one row per combination of
#' parent and subcommittee. The data returned for each subcommittee is the data
#' from the sub_committees table of its parent committee in the full table
#' returned from \code{fetch_committees}.
#'
#' Any committee that is a subcommittee will also be listed as a committee in
#' the table returned from \code{fetch_committees}, so you may wish to use the
#' results of \code{fetch_sub_committees} to filter the results of
#' \code{fetch_committees}.
#'
#' You can optionally use the \code{committees} argument to provide a vector of
#' committee ids and the function will return just the subcommittees of the
#' given parent committees.
#'
#' @param committees A vector of committee ids specifying the parent committees
#'   for which to return any subcommittees. The default is NULL, which returns
#'   data on subcommittees for all parent committees.
#' @param current A boolean indicating whether to return subcommittees for only
#'   those parent committees without an end date. The default is FALSE.
#' @export

fetch_sub_committees <- function(
    committees = NULL,
    current = FALSE) {

    # Fetch the full data on committees
    df <- fetch_committees(summary = FALSE, current = current)

    # Extract the subcommittees table from the list column and bind rows
    df <- purrr::pmap_df(
        list(df$committee_id, df$name, df$sub_committees),
        function(committee_id, commitee_name, sub_committees) {
            if (ncol(sub_committees) > 0) {
                sub_committees %>%
                    janitor::clean_names() %>%
                    dplyr::mutate(
                        committee_id = committee_id,
                        committee_name = commitee_name) %>%
                    dplyr::select(
                        .data$committee_id,
                        .data$committee_name,
                        sub_committee_id = .data$id,
                        sub_committee_name = .data$name,
                    dplyr::everything()) %>%
                    tibble::as_tibble()
            }
    })

    # Filter for just the sepcified committee ids
    if (! is.null(committees)) {
        df <- df %>% dplyr::filter(.data$committee_id %in% committees)
    }

    df
}

#' Fetch data on the current chairs of committees as a tibble
#'
#' \code{fetch_chairs} fetches data on the current chairs of comittees and
#' returns it as a tibble containing one row per combination of committee and
#' chair. The data returned for each chair is the data from the chairs table of
#' each committee in the full table returned from \code{fetch_committees}.
#'
#' You can optionally use the \code{committees} argument to provide a vector of
#' committee ids and the function will return just the current chairs of the
#' given committees.
#'
#' By default this function returns a subset of the columns and ignores any
#' nested and redundant columns. Set \code{summary = FALSE} when calling the
#' function to retrieve the full data.
#'
#' @param committees A vector of committee ids specifying the committees for
#'   which to return chairs. The default is NULL, which returns data on the
#'   chairs of all committees.
#' @param summary A boolean indicating whether to return the summary columns or
#'   the the full table. The default is TRUE.
#' @export

fetch_current_chairs <- function(
    committees = NULL,
    summary = TRUE) {

    # Fetch the full data on committees
    df <- fetch_committees(summary = FALSE, current = TRUE)

    # Extract the subcommittees table from the list column and bind rows
    df <- purrr::pmap_df(
        list(df$committee_id, df$name, df$chairs),
        function(committee_id, commitee_name, chairs) {
            if (ncol(chairs) > 0) {

                chairs <- chairs %>%
                    janitor::clean_names() %>%
                    dplyr::mutate(
                        committee_id = committee_id,
                        committee_name = commitee_name) %>%
                    dplyr::select(
                        .data$committee_id,
                        .data$committee_name,
                        chair_id = .data$id,
                        dplyr::everything()) %>%
                    tibble::as_tibble()

                # Remove nested and empty columns if summary is requested
                if (summary == TRUE) {
                    chairs <- chairs %>%
                        dplyr::select(
                            -.data$committee,
                            -.data$roles,
                            -.data$person)
                }

                # Shorten the mnis prefix for readability
                colnames(chairs) <- stringr::str_replace(
                    colnames(chairs), "mnis_person", "mnis")

                chairs
            }
        })

    # Filter for just the sepcified committee ids
    if (! is.null(committees)) {
        df <- df %>% dplyr::filter(.data$committee_id %in% committees)
    }

    df
}

#' Fetch data on the types of committees as a tibble
#'
#' \code{fetch_types} fetches data on the types of comittees and returns it as
#' a tibble containing one row per combination of committee and tyoe. The data
#' returned for each type is the data from the committee_types table of each
#' committee in the full table returned from \code{fetch_committees}.
#'
#' You can optionally use the \code{committees} argument to provide a vector of
#' committee ids and the function will return just the types of the given
#' committees.
#'
#' @param committees A vector of committee ids specifying the committees for
#'   which to return chairs. The default is NULL, which returns data on the
#'   chairs of all committees.
#' @param current A boolean indicating whether to return chairs for only
#'   those committees without an end date. The default is FALSE.
#' @export

fetch_committee_types <- function(
    committees = NULL,
    current = FALSE) {

    # Fetch the full data on committees
    df <- fetch_committees(summary = FALSE, current = current)

    # Extract the subcommittees table from the list column and bind rows
    df <- purrr::pmap_df(
        list(df$committee_id, df$name, df$committee_types),
        function(committee_id, commitee_name, committee_types) {
            if (ncol(committee_types) > 0) {
                committee_types %>%
                    janitor::clean_names() %>%
                    dplyr::mutate(
                        committee_id = committee_id,
                        committee_name = commitee_name) %>%
                    dplyr::select(
                        .data$committee_id,
                        .data$committee_name,
                        committee_type_id = .data$id,
                        dplyr::everything()) %>%
                    tibble::as_tibble()
            }
        })

    # Filter for just the sepcified committee ids
    if (! is.null(committees)) {
        df <- df %>% dplyr::filter(.data$committee_id %in% committees)
    }

    df
}


