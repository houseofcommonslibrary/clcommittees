### Functions for fetching data from the committee membership endpoints

# General membership functions ------------------------------------------------

#' Processes the data returned from a request to the membership endpoints.
#'
#' @param memberships A tibble returned from \code{request_items} called with
#'   the membership/member endpoint as the url.
#' @param summary A boolean indicating whether to return the summary columns or
#'   the full table. The default is TRUE.
#' @keywords internal

process_memberships <- function(memberships, summary = TRUE) {

    # Select only a subset of columns if requested
    if (summary == TRUE) {
        memberships <- memberships %>% dplyr::select(
            -.data$links,
            -.data$person,
            -.data$committee_id_2,
            -.data$committee_category,
            -.data$roles,
            -.data$committee_committee_types)
    }

    # Shorten mnis prefix for readability
    colnames(memberships) <- stringr::str_replace(
        colnames(memberships), "mnis_person", "mnis")

    # Reorder columns for readability
    memberships %>% dplyr::select(
        .data$committee_id,
        .data$committee_name,
        .data$mnis_id,
        .data$mnis_display_name,
        dplyr::everything())
}

# Fetch members functions -----------------------------------------------------

#' Fetch data on the current and former members of a committee as a tibble
#'
#' \code{fetch_members} fetches data on the current and former members of a
#' given committee and returns it as a tibble containing one row per committee
#' member.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the current and former members.
#' @param summary A boolean indicating whether to return the summary columns or
#'   the full table. The default is TRUE.
#' @export

fetch_memberships <- function(
    committee,
    summary = TRUE) {

    current_members <- fetch_current_memberships(committee, summary)
    full_members <- fetch_former_memberships(committee, summary)
    dplyr::bind_rows(current_members, full_members)
}

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

fetch_current_memberships <- function(
    committee,
    summary = TRUE) {

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/{committee}/membership/current?",
        "parameters.all=true"
    ))

    memberships <- request_items(url) %>%
        # Rename the id and name columns to be informative
        dplyr::rename(membership_id = .data$id)

    process_memberships(memberships, summary)

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

fetch_former_memberships <- function(
    committee,
    summary = TRUE) {

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/{committee}/membership/former?",
        "parameters.all=true"
    ))

    memberships <- request_items(url) %>%
        # Rename the id and name columns to be informative
        dplyr::rename(membership_id = .data$id)

    process_memberships(memberships, summary)
}

# Fetch memberships for functions ---------------------------------------------

fetch_memberships_for <- function(member, summary = TRUE) {

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/membership/member?",
        "parameters.members={member}"
    ))

    memberships <- request_items(url)
    process_memberships(memberships, summary)
}

fetch_current_memberships_for <- function(member, summary = TRUE) {

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/membership/member?",
        "parameters.former=false&parameters.members={member}"
    ))

    memberships <- request_items(url)
    process_memberships(memberships, summary)
}

fetch_former_memberships_for <- function(member, summary = TRUE) {

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/membership/member?",
        "parameters.former=true&parameters.members={member}"
    ))

    memberships <- request_items(url)
    process_memberships(memberships, summary)
}

# General roles functions -----------------------------------------------------

#' Processes the full table returned from \code{fetch_members} or
#'   \code{fetch_memberships_for} to exract the data on roles.
#'
#' @param roles A tibble returned from \code{fetch_members} or
#'   \code{fetch_memberships_for} called with \code{summary = FALSE}.
#' @export

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

# Fetch roles functions -------------------------------------------------------

#' Fetch data on the roles of the current and former members of a committee as
#' a tibble
#'
#' \code{fetch_roles} fetches data on the roles of the current and former
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

fetch_roles <- function(committee) {
    members <- fetch_memberships(committee, summary = FALSE)
    process_roles(members)
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
    current_members <- fetch_current_memberships(committee, summary = FALSE)
    process_roles(current_members)
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
    former_members <- fetch_former_memberships(committee, summary = FALSE)
    process_roles(former_members)
}

# Fetch roles for functions ---------------------------------------------------

fetch_roles_for <- function(member) {
    member <- fetch_memberships_for(member, summary = FALSE)
    process_roles(member)
}

fetch_current_roles_for <- function(member) {
    member <- fetch_current_memberships_for(member, summary = FALSE)
    process_roles(member)
}

fetch_former_roles_for <- function(member) {
    member <- fetch_former_memberships_for(member, summary = FALSE)
    process_roles(member)
}
