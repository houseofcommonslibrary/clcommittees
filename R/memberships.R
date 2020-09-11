### Functions for fetching data from the committee membership endpoints

# Fetch members functions -----------------------------------------------------

#' Fetch data on the current members of a committee as a tibble
#'
#' \code{fetch_current_members} fetches data on the current members of a given
#' committee and returns it as a tibble containing one row per committee
#' member.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the current members.
#' @param summary A boolean indicating whether to return the summary columns or
#'   the full table. The default is TRUE.
#' @export

fetch_current_members <- function(
    committee,
    summary = TRUE) {

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/{committee}/membership/current?",
        "parameters.all=true"
    ))

    cm <- request_items(url) %>%
        # Rename the id and name columns to be informative
        dplyr::rename(membership_id = .data$id)

    # Select only a subset of columns if requested
    if (summary == TRUE) {
        cm <- cm %>% dplyr::select(
            -.data$links,
            -.data$person,
            -.data$committee_id_2,
            -.data$committee_category,
            -.data$roles,
            -.data$committee_committee_types)
    }

    # Shorten mnis prefix for readability
    colnames(cm) <- stringr::str_replace(colnames(cm), "mnis_person", "mnis")

    # Reorder columns for readability
    cm <- cm %>% dplyr::select(
        .data$committee_id,
        .data$committee_name,
        .data$mnis_id,
        .data$mnis_display_name,
        dplyr::everything())

    cm
}

#' Fetch data on the former members of a committee as a tibble
#'
#' \code{fetch_former_members} fetches data on the former members of a given
#' committee and returns it as a tibble containing one row per committee
#' member.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the former members.
#' @param summary A boolean indicating whether to return the summary columns or
#'   the full table. The default is TRUE.
#' @export

fetch_former_members <- function(
    committee,
    summary = TRUE) {

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/{committee}/membership/former?",
        "parameters.all=true"
    ))

    fm <- request_items(url) %>%
        # Rename the id and name columns to be informative
        dplyr::rename(membership_id = .data$id)

    # Select only a subset of columns if requested
    if (summary == TRUE) {
        fm <- fm %>% dplyr::select(
            -.data$links,
            -.data$person,
            -.data$committee_id_2,
            -.data$committee_category,
            -.data$roles,
            -.data$committee_committee_types)
    }

    # Shorten mnis prefix for readability
    colnames(fm) <- stringr::str_replace(colnames(fm), "mnis_person", "mnis")

    # Reorder columns for readability
    fm <- fm %>% dplyr::select(
        .data$committee_id,
        .data$committee_name,
        .data$mnis_id,
        .data$mnis_display_name,
        dplyr::everything())

    fm
}

#' Fetch data on the current and former members of a committee as a tibble
#'
#' \code{fetch_all_members} fetches data on the current and former members of a
#' given committee and returns it as a tibble containing one row per committee
#' member.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the current and former members.
#' @param summary A boolean indicating whether to return the summary columns or
#'   the full table. The default is TRUE.
#' @export

fetch_all_members <- function(
    committee,
    summary = TRUE) {

    cm <- fetch_current_members(committee, summary)
    fm <- fetch_former_members(committee, summary)
    dplyr::bind_rows(cm, fm)
}

# Fetch roles functions ------------------------------------------------

#' Processes the full table returned from a \code{get_x_members} function to
#' exract the data on roles.
#'
#' @param roles A tibble returned from a \code{get_x_members} function called
#'   with \code{summary = FALSE}.
#' @keywords internal

process_roles <- function(roles) {

    roles <- purrr::pmap_df(
        list(
            roles$committee_id,
            roles$committee_name,
            roles$mnis_id,
            roles$mnis_display_name,
            roles$roles),
        function(
            committee_id,
            committee_name,
            mnis_id,
            mnis_display_name,
            roles) {

            if (ncol(roles) > 0) {
                roles %>% dplyr::mutate(
                    committee_id = committee_id,
                    committee_name = committee_name,
                    mnis_id = mnis_id,
                    mnis_display_name)
            }
        })

    # Clean column names and set column order
    roles <- roles %>%
        janitor::clean_names() %>%
        dplyr::select(
            .data$committee_id,
            .data$committee_name,
            .data$mnis_id,
            .data$mnis_display_name,
            dplyr::everything()) %>%
        tibble::as_tibble()

    # Convert date columns to Date
    roles$start_date <- as.Date(roles$start_date)
    roles$end_date <- as.Date(roles$end_date)

    roles
}

#' Fetch data on the roles of the current members of a committee as a tibble
#'
#' \code{fetch_curent_roles} fetches data on the roles of the current members
#' of a given committee and returns it as a tibble containing one row per
#' committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns ALL the roles for this committee (both current and historic) for its
#' current members. A role without an end date is a current role.
#'
#' A member may have concurrent roles for the same period reflecting different
#' positions e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the roles for the current members.
#' @export

fetch_current_roles <- function(committee) {
    cm <- fetch_current_members(committee, summary = FALSE)
    cr <- process_roles(cm)
    cr
}

#' Fetch data on the roles of the former members of a committee as aåtibble
#'
#' \code{fetch_former_roles} fetches data on the roles of the former members of
#' a given committee and returns it as a tibble containing one row per
#' committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns ALL the roles for this committee held by its former members.
#'
#' A member may have concurrent roles for the same period reflecting different
#' positions e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the roles for the former members.
#' @export

fetch_former_roles <- function(committee) {
    fm <- fetch_former_members(committee, summary = FALSE)
    fr <- process_roles(fm)
    fr
}

#' Fetch data on the roles of the current and former members of a committee as
#' a tibble
#'
#' \code{fetch_all_roles} fetches data on the roles of the current and former
#' members of a given committee and returns it as a tibble containing one row
#' per committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns ALL the roles for this committee (both current and historic) for its
#' current and former members. A role without an end date is a current role.
#'
#' A member may have concurrent roles for the same period reflecting different
#' roles e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the roles for the former members.
#' @export

fetch_all_roles <- function(committee) {
    am <- fetch_all_members(committee, summary = FALSE)
    ar <- process_roles(am)
    ar
}

