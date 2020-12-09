### Functions for fetching data from the committees endpoint

# Committees ------------------------------------------------------------------

#' Fetch data on current and former committees as a tibble using a Members
#' endpoint URL
#'
#' \code{fetch_committees_from_url} fetches data on committees from a Members
#' endpoint URL and returns it as a tibble containing one row per committee.
#' This internal function allows generic handling of requests for this data
#' to the Members endpoint with different URL parameters.
#'
#' @param url A valid URL requesting data from the Committees endpoint.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @keywords internal

fetch_committees_for_url <- function(url, summary = TRUE) {

    # Fetch the data
    cm <- request_items(url)
    if (nrow(cm) == 0) return(cm)

    # Rename the id and name columns to be informative
    cm <- cm %>% dplyr::rename(
        committee_id = .data$id,
        committee_name = .data$name)

    # Convert date columns to Date
    cm$start_date <- as.Date(cm$start_date)
    cm$end_date <- as.Date(cm$end_date)
    cm$date_commons_appointed <- as.Date(cm$date_commons_appointed)
    cm$date_lords_appointed <- as.Date(cm$date_lords_appointed)

    # Remove nested and empty columns if summary is requested
    if (summary == TRUE) {
        cm <- cm %>%
            dplyr::select(function(c) ! is.list(c)) %>%
            dplyr::select(function(c) ! all(is.na(c)), .data$end_date) %>%
            dplyr::select(
                .data$committee_id,
                .data$committee_name,
                .data$start_date,
                .data$end_date,
                .data$house,
                dplyr::everything())
    }

    cm
}

#' Fetch data on current and former committees as a tibble
#'
#' \code{fetch_committees} fetches data on current and former committees and
#' returns it as a tibble containing one row per committee.
#'
#' By default this function returns a subset of the columns and ignores any
#' nested and redundant columns. Set \code{summary = FALSE} when calling the
#' function to retrieve the full data.
#'
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_committees <- function(summary = TRUE) {

    # Fetch data for all committees
    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees?Take={PARAMETER_TAKE_THRESHOLD}",
        "&CommitteeStatus=All"))

    fetch_committees_for_url(url, summary = summary)
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
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_current_committees <- function(summary = TRUE) {

    # Fetch data for current committees
    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees?Take={PARAMETER_TAKE_THRESHOLD}",
        "&CommitteeStatus=Current"))

    fetch_committees_for_url(url, summary = summary)
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
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_former_committees <- function(summary = TRUE) {

    # Fetch data for former committees
    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees?Take={PARAMETER_TAKE_THRESHOLD}",
        "&CommitteeStatus=Former"))

    fetch_committees_for_url(url, summary = summary)
}

# Sub-committees --------------------------------------------------------------

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
#' By default this function returns a subset of the columns and ignores any
#' nested and redundant columns. Set \code{summary = FALSE} when calling the
#' function to retrieve the full data.
#'
#' @param committees A vector of committee ids specifying the parent committees
#'   for which to return any subcommittees. The default is NULL, which returns
#'   data on subcommittees for all parent committees.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_sub_committees <- function(committees = NULL, summary = TRUE) {

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

    # Remove nested and empty columns if summary is requested
    if (summary == TRUE) {
        sc <- sc %>%
            dplyr::select(function(c) ! is.list(c)) %>%
            dplyr::select(function(c) ! all(is.na(c)), .data$end_date)
    }

    # Filter for just the specified committee ids
    if (! is.null(committees)) {
        sc <- sc %>% dplyr::filter(.data$committee_id %in% committees)
    }

    sc
}

#' Fetch data on the types of committees as a tibble
#'
#' \code{fetch_committee_types} fetches data on the types of comittees and
#' returns it as a tibble containing one row per combination of committee and
#' type. The data returned for each type is the data from the committee_types
#' table of each committee in the full table returned from
#' \code{fetch_committees}.
#'
#' You can optionally use the \code{committees} argument to provide a vector of
#' committee ids and the function will return just the types of the given
#' committees.
#'
#' @param committees A vector of committee ids specifying the committees for
#'   which to return types. The default is NULL, which returns data on the
#'   types of all committees.
#' @export

fetch_committee_types <- function(committees = NULL) {

    # Fetch the full data on committees
    cm <- fetch_committees(summary = FALSE)

    # Extract the committee types table from the list column and bind rows
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

#' Fetch data on the departments scrutinised by committees as a tibble
#'
#' \code{fetch_scrutinising_departments} fetches data on the government
#' departments scrutinised by comittees and returns it as a tibble containing
#' one row per combination of committee and department. The data returned for
#' each department is the data from the scrutinising_departments table of each
#' committee in the full table returned from \code{fetch_committees}.
#'
#' You can optionally use the \code{committees} argument to provide a vector of
#' committee ids and the function will return just the departments of the given
#' committees.
#'
#' @param committees A vector of committee ids specifying the committees for
#'   which to return departments. The default is NULL, which returns data on
#'   the departments scrutinised by all committees.
#' @export

fetch_scrutinising_departments <- function(committees = NULL) {

    # Fetch the full data on committees
    cm <- fetch_committees(summary = FALSE)

    # Extract the scrutinising departments from the list column and bind rows
    sd <- purrr::pmap_df(
        list(
            cm$committee_id,
            cm$committee_name,
            cm$scrutinising_departments),
        function(
            committee_id,
            commitee_name,
            scrutinising_departments) {

            if (ncol(scrutinising_departments) > 0) {
                scrutinising_departments %>% dplyr::mutate(
                    committee_id = committee_id,
                    committee_name = commitee_name)
            }
        })

    # Clean column names and set column order
    sd <- sd %>%
        janitor::clean_names() %>%
        dplyr::select(
            .data$committee_id,
            .data$committee_name,
            .data$department_id,
            dplyr::everything()) %>%
        tibble::as_tibble()

    # Filter for just the specified committee ids
    if (! is.null(committees)) {
        sd <- sd %>% dplyr::filter(.data$committee_id %in% committees)
    }

    sd
}
