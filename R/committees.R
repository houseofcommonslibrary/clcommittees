### Functions for fetching data from the committees endpoint

# Committees ------------------------------------------------------------------

#' Fetch data on current and former committees as a tibble
#'
#' \code{fetch_committees} fetches data on current and former committees and
#' returns it as a tibble containing one row per committee.
#'
#' By default this function returns a subset of the columns and ignores any
#' nested and redundant columns. Set \code{summary = FALSE} when calling the
#' function to retrieve the full data.
#'
#' @param summary A boolean indicating whether to return the summary columns or
#'   the the full table. The default is TRUE.
#' @export

fetch_committees <- function(summary = TRUE) {

    # Get data for all committees
    url <- stringr::str_c(
        "https://committees-api.parliament.uk/committees?",
        "parameters.all=true&",
        "parameters.currentOnly=false")

    cm <- request_items(url) %>%
        # Rename the id and name columns to be informative
        dplyr::rename(
            committee_id = .data$id,
            committee_name = .data$name)

    # Convert date columns to Date
    cm$start_date <- as.Date(cm$start_date)
    cm$end_date <- as.Date(cm$end_date)
    cm$date_commons_appointed <- as.Date(cm$date_commons_appointed)
    cm$date_lords_appointed <- as.Date(cm$date_lords_appointed)

    # Select only a subset of columns if requested
    if (summary == TRUE) {
        cm <- cm %>% dplyr::select(
            .data$committee_id,
            .data$committee_name,
            .data$start_date,
            .data$end_date,
            .data$is_commons,
            .data$is_lords,
            .data$email,
            .data$phone,
            .data$category_id,
            .data$category_name)
    }

    cm
}

#' Fetch data on current committees as a tibble
#'
#' \code{fetch_current_committees} fetches data on current committees and
#' returns it as a tibble containing one row per committee. Current committees
#' are those that do not have an end date.
#'
#' By default this function returns a subset of the columns and ignores any
#' nested and redundant columns. Set \code{summary = FALSE} when calling the
#' function to retrieve the full data.
#'
#' @param summary A boolean indicating whether to return the summary columns or
#'   the the full table. The default is TRUE.
#' @export

fetch_current_committees <- function(summary = TRUE) {
    cm <- fetch_committees(summary = summary)
    cm <- cm %>% dplyr::filter(is.na(.data$end_date))
}

#' Fetch data on former committees as a tibble
#'
#' \code{fetch_former_committees} fetches data on foremr committees and
#' returns it as a tibble containing one row per committee. Former committees
#' are those that have an end date.
#'
#' By default this function returns a subset of the columns and ignores any
#' nested and redundant columns. Set \code{summary = FALSE} when calling the
#' function to retrieve the full data.
#'
#' @param summary A boolean indicating whether to return the summary columns or
#'   the the full table. The default is TRUE.
#' @export

fetch_former_committees <- function(summary = TRUE) {
    cm <- fetch_committees(summary = summary)
    cm <- cm %>% dplyr::filter(! is.na(.data$end_date))
}

# Sub-committees ------------------------------------------------------------------

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
#' @export

fetch_sub_committees <- function(committees = NULL) {

    # Fetch the full data on committees
    cm <- fetch_committees(summary = FALSE)

    # Extract the subcommittees table from the list column and bind rows
    sc <- purrr::pmap_df(
        list(
            cm$committee_id,
            cm$committee_name,
            cm$sub_committees),
        function(
            committee_id,
            commitee_name,
            sub_committees) {

            if (ncol(sub_committees) > 0) {
                sub_committees %>% dplyr::mutate(
                    committee_id = committee_id,
                    committee_name = commitee_name)
            }
    })

    # Clean column names and set column order
    sc <- sc %>%
        janitor::clean_names() %>%
        dplyr::select(
            .data$committee_id,
            .data$committee_name,
            sub_committee_id = .data$id,
            sub_committee_name = .data$name,
            dplyr::everything()) %>%
        tibble::as_tibble()

    # Filter for just the specified committee ids
    if (! is.null(committees)) {
        sc <- sc %>% dplyr::filter(.data$committee_id %in% committees)
    }

    sc
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
#' @export

fetch_committee_types <- function(committees = NULL) {

    # Fetch the full data on committees
    cm <- fetch_committees(summary = FALSE)

    # Extract the subcommittees table from the list column and bind rows
    ct <- purrr::pmap_df(
        list(
            cm$committee_id,
            cm$committee_name,
            cm$committee_types),
        function(
            committee_id,
            commitee_name,
            committee_types) {

            if (ncol(committee_types) > 0) {
                committee_types %>% dplyr::mutate(
                    committee_id = committee_id,
                    committee_name = commitee_name)
            }
        })

    # Clean column names and set column order
    ct <- ct %>%
        janitor::clean_names() %>%
        dplyr::select(
            .data$committee_id,
            .data$committee_name,
            committee_type_id = .data$id,
            dplyr::everything()) %>%
        tibble::as_tibble()

    # Filter for just the specified committee ids
    if (! is.null(committees)) {
        ct <- ct %>% dplyr::filter(.data$committee_id %in% committees)
    }

    ct
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
    cm <- fetch_committees(summary = FALSE)

    # Extract the subcommittees table from the list column and bind rows
    ch <- purrr::map2_df(
        cm$committee_name,
        cm$chairs,
        function(commitee_name, chairs) {
            if (ncol(chairs) > 0) {
                chairs %>% dplyr::mutate(committee_name = commitee_name)
            }
        })

    # Clean column names and set column order
    ch <- ch %>%
        janitor::clean_names() %>%
        dplyr::select(
            .data$committee_id,
            .data$committee_name,
            chair_id = .data$id,
            dplyr::everything()) %>%
        tibble::as_tibble()

    # Remove nested and empty columns if summary is requested
    if (summary == TRUE) {
        ch <- ch %>%
            dplyr::select(
                -.data$committee,
                -.data$roles,
                -.data$person)
    }

    # Shorten mnis prefix for readability
    colnames(ch) <- stringr::str_replace(colnames(ch), "mnis_person", "mnis")

    # Filter for just the specified committee ids
    if (! is.null(committees)) {
        ch <- ch %>% dplyr::filter(.data$committee_id %in% committees)
    }

    ch
}
