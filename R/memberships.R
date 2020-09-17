### Functions for fetching data from the committee membership endpoints

# General membership functions ------------------------------------------------

#' Processes a tibble returned from \code{request_items} when called with the
#' url of either the member or membership endpoint.
#'
#' @param memberships A tibble returned from \code{request_items} called with
#'   the membership/member endpoint as the url.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @keywords internal

process_memberships <- function(memberships, summary = TRUE) {

    if (nrow(memberships) == 0) return(memberships)

    # Remove nested and empty columns if summary is requested
    if (summary == TRUE) {
        memberships <- memberships %>%
            dplyr::select_if(function(c) ! is.list(c)) %>%
            dplyr::select_if(function(c) ! all(is.na(c)))
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

#' Check that a committee argument to a membership function returns only one
#' committee
#'
#' @param committee A vector of committee ids that should contain only one id.
#' @keywords internal

check_committee_arg <- function(committee) {
    if (length(committee) > 1) {
        stop("The committee argument must be a single committee id")
    }
}

#' Check that a member argument to a membership function returns only one
#' member
#'
#' @param committee A vector of mnis ids that should contain only one id.
#' @keywords internal

check_member_arg <- function(member) {
    if (length(member) > 1) {
        stop("The member argument must be a single mnis id")
    }
}

# Fetch membership functions --------------------------------------------------

#' Fetch data on the current and former members of a committee as a tibble
#'
#' \code{fetch_memberships} fetches data on the current and former members of a
#' given committee and returns it as a tibble containing one row per committee
#' membership.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the current and former memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_memberships <- function(
    committee,
    summary = TRUE) {

    check_committee_arg(committee)
    current_members <- fetch_current_memberships(committee, summary)
    full_members <- fetch_former_memberships(committee, summary)
    dplyr::bind_rows(current_members, full_members)
}

#' Fetch data on the current members of a committee as a tibble
#'
#' \code{fetch_current_memberships} fetches data on the current members of a
#' given committee and returns it as a tibble containing one row per committee
#' membership.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the current memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_current_memberships <- function(
    committee,
    summary = TRUE) {

    check_committee_arg(committee)

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/{committee}/membership/current?",
        "parameters.all=true"
    ))

    memberships <- request_items(url)
    if (nrow(memberships) == 0) return(memberships)

    memberships <-  memberships %>%
        # Rename the id and name columns to be informative
        dplyr::rename(membership_id = .data$id)

    process_memberships(memberships, summary)

}

#' Fetch data on the former members of a committee as a tibble
#'
#' \code{fetch_former_memberships} fetches data on the former members of a
#' given committee and returns it as a tibble containing one row per committee
#' membership.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the former memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_former_memberships <- function(
    committee,
    summary = TRUE) {

    check_committee_arg(committee)

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/{committee}/membership/former?",
        "parameters.all=true"
    ))

    memberships <- request_items(url)
    if (nrow(memberships) == 0) return(memberships)

    memberships <-  memberships %>%
        # Rename the id and name columns to be informative
        dplyr::rename(membership_id = .data$id)

    process_memberships(memberships, summary)
}

# Fetch memberships for member functions --------------------------------------

#' Fetch data on the current and former committee memberships of a given member
#'
#' \code{fetch_memberships_for_member} fetches data on the current and former
#' committee memberships of a given member and returns it as a tibble
#' containing one row per committee membership.
#'
#' @param member An integer representing the mnis_id of the member for which
#'   to fetch the current and former memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_memberships_for_member <- function(
    member,
    summary = TRUE) {

    check_member_arg(member)

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/membership/member?",
        "parameters.members={member}"
    ))

    memberships <- request_items(url)
    process_memberships(memberships, summary)
}

#' Fetch data on the current committee memberships of a given member
#'
#' \code{fetch_current_memberships_for_member} fetches data on the current
#' committee memberships of a given member and returns it as a tibble
#' containing one row per committee membership.
#'
#' @param member An integer representing the mnis_id of the member for which
#'   to fetch the current memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_current_memberships_for_member <- function(
    member,
    summary = TRUE) {

    check_member_arg(member)

    url <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/membership/member?",
        "parameters.former=false&parameters.members={member}"
    ))

    memberships <- request_items(url)
    process_memberships(memberships, summary)
}

#' Fetch data on the current committee memberships of a given member
#'
#' \code{fetch_former_memberships_for_member} fetches data on the former
#' committee memberships of a given member and returns it as a tibble
#' containing one row per committee membership.
#'
#' @param member An integer representing the mnis_id of the member for which
#'   to fetch the former memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_former_memberships_for_member <- function(
    member,
    summary = TRUE) {

    check_member_arg(member)

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
#'   \code{fetch_memberships_for_member} to extract the data on roles.
#'
#' @param roles A tibble returned from \code{fetch_members} or
#'   \code{fetch_memberships_for_member} called with \code{summary = FALSE}.
#' @keywords internal

process_roles <- function(roles) {

    if (nrow(roles) == 0) return(roles)

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
            .data$role_id,
            .data$role_name,
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
#' positions e.g. one indicating their service as a member and another their
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

# Fetch roles for member functions ---------------------------------------------------

#' Fetch data on the current and former committee roles of a given member
#'
#' \code{fetch_roles_for_member} fetches data on the current and former
#' committee roles of a given member and returns it as a tibble containing one
#' row per committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns ALL the roles for this member (both current and historic). A role
#' without an end date is a current role.
#'
#' A member may have concurrent roles for the same period reflecting different
#' positions e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param member An integer representing the mnis_id of the member for which to
#'   fetch the current and former roles.
#' @export

fetch_roles_for_member <- function(member) {
    member <- fetch_memberships_for_member(member, summary = FALSE)
    process_roles(member)
}

#' Fetch data on the current committee roles of a given member
#'
#' \code{fetch_current_roles_for_member} fetches data on the current committee
#' roles of a given member and returns it as a tibble containing one row per
#' committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns the current roles for this member.
#'
#' A member may have concurrent roles for the same period reflecting different
#' positions e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param member An integer representing the mnis_id of the member for which to
#'   fetch the current roles.
#' @export

fetch_current_roles_for_member <- function(member) {
    member <- fetch_current_memberships_for_member(member, summary = FALSE)
    process_roles(member)
}

#' Fetch data on the former committee roles of a given member
#'
#' \code{fetch_former_roles_for_member} fetches data on the former committee
#' roles of a given member and returns it as a tibble containing one row per
#' committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns the former roles for this member.
#'
#' A member may have concurrent roles for the same period reflecting different
#' positions e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param member An integer representing the mnis_id of the member for which to
#'   fetch the current roles.
#' @export

fetch_former_roles_for_member <- function(member) {
    member <- fetch_former_memberships_for_member(member, summary = FALSE)
    process_roles(member)
}
