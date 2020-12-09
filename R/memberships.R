### Functions for fetching data from the committee membership endpoints

# Fetch membership functions --------------------------------------------------

#' Check that a committee argument to a membership function returns only one
#' committee
#'
#' @param committee_id A single committee id.
#' @keywords internal

check_committee_id <- function(committee_id) {
    if (length(committee_id) > 1) {
        stop("The committee_id argument must be a single committee id")
    }
}

#' Fetch data on members of a given committee as a tibble using a Members
#' endpoint URL
#'
#' \code{fetch_memberships_from_url} fetches data on the members of a given
#' committee from a Members endpoint URL and returns it as a tibble containing
#' one row per committee membership. This internal function allows generic
#' handling of requests for this data to the Members endpoint with different
#' URL parameters.
#'
#' @param committee_id An integer representing the id of the committee for
#'   which to fetch members.
#' @param url A valid URL requesting data for the given committee id from the
#'   Memberships endpoint.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @param fetch_name A boolean indicating whether to add the committee name
#'   by making an extra call to the API. The default is TRUE.
#' @keywords internal

fetch_memberships_from_url <- function(
    committee_id,
    url,
    summary = TRUE,
    fetch_name = TRUE) {

    # Get the memberships for this url
    ms <- request_items(url)
    if (nrow(ms) == 0) return(ms)

    # Set committee name to unknown by default
    committee_name <- NA

    # Fetch committee name if requested
    if (fetch_name == TRUE) {
        cm <- fetch_committees()
        cm <- cm[cm$committee_id == committee_id, ]
        committee_name <- cm$committee_name[1]
    }

    # Shorten mnis prefix for readability
    colnames(ms) <- stringr::str_replace(
        colnames(ms), "member_info_", "")

    # Reorder columns for readability
    ms <- ms %>%
        dplyr::mutate(
            committee_id = committee_id,
            committee_name = committee_name) %>%
        dplyr::select(
            .data$committee_id,
            .data$committee_name,
            .data$mnis_id,
            .data$display_as,
            dplyr::everything())

    # Remove nested and empty columns if summary is requested
    if (summary == TRUE) {
        ms <- ms %>%
            dplyr::select_if(function(c) ! is.list(c)) %>%
            dplyr::select_if(function(c) ! all(is.na(c)))
    }

    ms
}

#' Fetch data on the current and former members of a committee as a tibble
#'
#' \code{fetch_memberships} fetches data on the current and former members of a
#' given committee and returns it as a tibble containing one row per committee
#' membership.
#'
#' @param committee_id An integer representing the id of the committee for
#'   which to fetch the current and former members.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @param fetch_name A boolean indicating whether to add the committee name
#'   by making an extra call to the API. The default is TRUE.
#' @export

fetch_memberships <- function(
    committee_id,
    summary = TRUE,
    fetch_name = TRUE) {

    check_committee_id(committee_id)
    if (committee_id < 1) return(tibble::tibble())

    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees/{format_ids(committee_id)}/Members?",
        "Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=All"))

    fetch_memberships_from_url(
        committee_id,
        url,
        summary = summary,
        fetch_name = fetch_name)
}

#' Fetch data on the current members of a committee as a tibble
#'
#' \code{fetch_current_memberships} fetches data on the current members of a
#' given committee and returns it as a tibble containing one row per committee
#' membership.
#'
#' @param committee_id An integer representing the id of the committee for
#'   which to fetch the current members.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @param fetch_name A boolean indicating whether to add the committee name
#'   by making an extra call to the API. The default is TRUE.
#' @export

fetch_current_memberships <- function(
    committee_id,
    summary = TRUE,
    fetch_name = TRUE) {

    check_committee_id(committee_id)
    if (committee_id < 1) return(tibble::tibble())

    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees/{format_ids(committee_id)}/Members?",
        "Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Current"))

    fetch_memberships_from_url(
        committee_id,
        url,
        summary = summary,
        fetch_name = fetch_name)
}

#' Fetch data on the former members of a committee as a tibble
#'
#' \code{fetch_former_memberships} fetches data on the former members of a
#' given committee and returns it as a tibble containing one row per committee
#' membership.
#'
#' @param committee_id An integer representing the id of the committee for
#'   which to fetch the former memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @param fetch_name A boolean indicating whether to add the committee name
#'   by making an extra call to the API. The default is TRUE.
#' @export

fetch_former_memberships <- function(
    committee_id,
    summary = TRUE,
    fetch_name = TRUE) {

    check_committee_id(committee_id)
    if (committee_id < 1) return(tibble::tibble())

    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees/{format_ids(committee_id)}/Members?",
        "Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Former"))

    fetch_memberships_from_url(
        committee_id,
        url,
        summary = summary,
        fetch_name = fetch_name)
}

# Fetch memberships for member functions --------------------------------------

#' Check that a member_id argument to a membership function returns only one
#' member
#'
#' @param member_id A single mnis_id.
#' @keywords internal

check_member_id <- function(member_id) {
    if (length(member_id) > 1) {
        stop("The member_id argument must be a single mnis id")
    }
}

#' Fetch data on the committee memberships of a given member as a tibble using
#' a Members endpoint URL
#'
#' \code{fetch_memberships_for_member_from_url} fetches data on the committee
#' memberships of a given member from a Members endpoint URL and returns it as
#' a tibble containing one row per committee membership. This internal function
#' allows generic handling of requests for this data to the Members endpoint
#' with different URL parameters.
#'
#' @param url A valid URL requesting data for the given member id from the
#'   Members endpoint.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_memberships_for_member_from_url <- function(url, summary = TRUE) {

    # Get the table for the member
    member <- request(url) %>%
        tibble::as_tibble() %>%
        janitor::clean_names()

    if (nrow(member) == 0) return(member)

    # Extract the nested committees table for the member
    committees <- member$committees[[1]] %>%
        tibble::as_tibble() %>%
        janitor::clean_names() %>%
        dplyr::rename(
            committee_id = .data$id,
            committee_name = .data$name)

    # Organise the member table and remove redundant data
    member <- member %>%  dplyr::select(
        mnis_id = .data$member_info_mnis_id,
        person_id = .data$person_id,
        name = .data$name,
        photo_url = .data$photo_url,
        dplyr::everything()) %>%
        dplyr::select(-c(.data$id, .data$committees))

    # Shorten mnis prefix for readability
    colnames(member) <- stringr::str_replace(
        colnames(member), "member_info_", "")

    # Combine member and committee data into a single table
    memberships <- committees %>% dplyr::mutate(
        mnis_id = member$mnis_id,
        person_id = member$person_id,
        name = member$name,
        photo_url = member$photo_url,
        member_from = member$member_from,
        party = member$party,
        party_colour = member$party_colour,
        is_chair = member$is_chair,
        list_as = member$list_as,
        display_as = member$display_as,
        full_title = member$full_title,
        address_as = member$address_as,
        house = member$house,
        is_current = member$is_current) %>%
        dplyr::select(
            .data$committee_id,
            .data$committee_name,
            .data$mnis_id,
            .data$display_as,
            dplyr::everything())

    # Remove nested and empty columns if summary is requested
    if (summary == TRUE) {
        memberships <- memberships %>%
            dplyr::select_if(function(c) ! is.list(c)) %>%
            dplyr::select_if(function(c) ! all(is.na(c)))
    }

    memberships
}

#' Fetch data on the current and former committee memberships of a given member
#'
#' \code{fetch_memberships_for_member} fetches data on the current and former
#' committee memberships of a given member and returns it as a tibble
#' containing one row per committee membership.
#'
#' @param member_id An integer representing the mnis_id of the member for which
#'   to fetch the current and former memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_memberships_for_member <- function(member_id, summary = TRUE) {

    check_member_id(member_id)
    if (member_id < 1) return(tibble::tibble())

    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Members?Members={format_ids(member_id)}",
        "&Take={PARAMETER_TAKE_THRESHOLD}"))

    fetch_memberships_for_member_from_url(url, summary = summary)
}

#' Fetch data on the current committee memberships of a given member
#'
#' \code{fetch_current_memberships_for_member} fetches data on the current
#' committee memberships of a given member and returns it as a tibble
#' containing one row per committee membership.
#'
#' @param member_id An integer representing the mnis_id of the member for which
#'   to fetch the current memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_current_memberships_for_member <- function(
    member_id, summary = TRUE) {

    check_member_id(member_id)
    if (member_id < 1) return(tibble::tibble())

    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Members?Members={format_ids(member_id)}",
        "&Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Current"))

    fetch_memberships_for_member_from_url(url, summary = summary)
}

#' Fetch data on the former committee memberships of a given member
#'
#' \code{fetch_former_memberships_for_member} fetches data on the former
#' committee memberships of a given member and returns it as a tibble
#' containing one row per committee membership.
#'
#' @param member_id An integer representing the mnis_id of the member for which
#'   to fetch the former memberships.
#' @param summary A boolean indicating whether to exclude nested and empty
#'   columns in the results. The default is TRUE.
#' @export

fetch_former_memberships_for_member <- function(member_id, summary = TRUE) {

    check_member_id(member_id)
    if (member_id < 1) return(tibble::tibble())

    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Members?Members={format_ids(member_id)}",
        "&Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Former"))

    fetch_memberships_for_member_from_url(url, summary = summary)
}

# General roles functions -----------------------------------------------------

#' Processes the full table returned from \code{fetch_memberships} or
#'   \code{fetch_memberships_for_member} to extract the data on roles.
#'
#' @param roles A tibble returned from \code{fetch_memberships} or
#'   \code{fetch_memberships_for_member} called with \code{summary = FALSE}.
#' @keywords internal

process_roles <- function(roles) {

    roles <- purrr::pmap_df(
        list(
            roles$committee_id,
            roles$committee_name,
            roles$mnis_id,
            roles$display_as,
            roles$roles),
        function(
            committee_id,
            committee_name,
            mnis_id,
            display_as,
            roles) {

            if (ncol(roles) > 0) {
                roles %>% dplyr::mutate(
                    committee_id = committee_id,
                    committee_name = committee_name,
                    mnis_id = mnis_id,
                    display_as)
            }
        })

    # Clean column names and set column order
    roles <- roles %>%
        janitor::clean_names() %>%
        dplyr::select(
            .data$committee_id,
            .data$committee_name,
            .data$mnis_id,
            .data$display_as,
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
#' \code{fetch_member_roles} fetches data on the roles of the current and
#' former members of a given committee and returns it as a tibble containing
#' one row per committee role.
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

fetch_member_roles <- function(committee) {
    memberships <- fetch_memberships(committee, summary = FALSE)
    if (nrow(memberships) == 0) return(memberships)
    process_roles(memberships)
}

#' Fetch data on the roles of the current members of a committee as a tibble
#'
#' \code{fetch_curent_member_roles} fetches data on the roles of the current
#' members of a given committee and returns it as a tibble containing one row
#' per committee role.
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

fetch_current_member_roles <- function(committee) {
    memberships <- fetch_current_memberships(committee, summary = FALSE)
    if (nrow(memberships) == 0) return(memberships)
    process_roles(memberships)
}

#' Fetch data on the roles of the former members of a committee as a tibble
#'
#' \code{fetch_former_member_roles} fetches data on the roles of the former
#' members of a given committee and returns it as a tibble containing one row
#' per committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns ALL the roles for this committee for its former members. A role
#' without an end date is a current role.
#'
#' A member may have concurrent roles for the same period reflecting different
#' positions e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param committee An integer representing the id of the committee for which
#'   to fetch the roles for the former members.
#' @export

fetch_former_member_roles <- function(committee) {
    memberships <- fetch_former_memberships(committee, summary = FALSE)
    if (nrow(memberships) == 0) return(memberships)
    process_roles(memberships)
}

# Fetch roles for member functions --------------------------------------------

#' Fetch data on the current and former committee roles of a given member
#'
#' \code{fetch_roles_for_member} fetches data on the current and former
#' committee roles of a given member and returns it as a tibble containing one
#' row per committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns the member's current and former roles. A role without an end date is
#' a current role.
#'
#' A member may have concurrent roles for the same period reflecting different
#' positions e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param member An integer representing the mnis_id of the member for which to
#'   fetch the current and former roles.
#' @export

fetch_roles_for_member <- function(member) {
    memberships <- fetch_memberships_for_member(member, summary = FALSE)
    if (nrow(memberships) == 0) return(memberships)
    process_roles(memberships)
}

#' Fetch data on the current committee roles of a given member
#'
#' \code{fetch_current_roles_for_member} fetches data on the current committee
#' roles of a given member and returns it as a tibble containing one row per
#' committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns the member's the current roles. A role without an end date is a
#' current role.
#'
#' A member may have concurrent roles for the same period reflecting different
#' positions e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param member An integer representing the mnis_id of the member for which to
#'   fetch the current roles.
#' @export

fetch_current_roles_for_member <- function(member) {
    memberships <- fetch_memberships_for_member(member, summary = FALSE)
    if (nrow(memberships) == 0) return(memberships)
    roles <- process_roles(memberships)
    roles %>% dplyr::filter(is.na(.data$end_date))
}

#' Fetch data on the former committee roles of a given member
#'
#' \code{fetch_former_roles_for_member} fetches data on the former committee
#' roles of a given member and returns it as a tibble containing one row per
#' committee role.
#'
#' A role indicates a period of service in a given position, so this function
#' returns the member's the former roles. A role without an end date is a
#' current role.
#'
#' A member may have concurrent roles for the same period reflecting different
#' positions e.g. one indicating their service as a member and another their
#' service as a chair.
#'
#' @param member An integer representing the mnis_id of the member for which to
#'   fetch the current roles.
#' @export

fetch_former_roles_for_member <- function(member) {
    memberships <- fetch_memberships_for_member(member, summary = FALSE)
    if (nrow(memberships) == 0) return(memberships)
    roles <- process_roles(memberships)
    roles %>% dplyr::filter(! is.na(.data$end_date))
}
