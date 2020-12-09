### Record and retrieve test data: membership functions

# About -----------------------------------------------------------------------

# WARNING: RUNNING THIS FILE WILL REBUILD THE TEST DATA FOR THESE FUNCTIONS
#
# The functions in this file are used to record the output of the api and the
# functions that process that data in order to produce mocks, and to check if
# the expected behaviour of the functions has changed. The file paths are set
# so that you can source this file from within the package project during
# development to generate the test data, and source the test data files from
# within the corresponding tests. Only run this run file when you are ready
# to capture current behaviour.

# Imports ---------------------------------------------------------------------

source("tests/testthat/data.R")

# Fetch test data for core functions ------------------------------------------

fetch_memberships_data <- function() {

    url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees/{COMMITTEE_ID}/Members?",
        "Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=All"))

    url_current <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees/{COMMITTEE_ID}/Members?",
        "Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Current"))

    url_former <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees/{COMMITTEE_ID}/Members?",
        "Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Former"))

    url_for_member <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Members?Members={MEMBER_ID}",
        "&Take={PARAMETER_TAKE_THRESHOLD}"))

    url_current_for_member <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Members?Members={MEMBER_ID}",
        "&Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Current"))

    url_former_for_member <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Members?Members={MEMBER_ID}",
        "&Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Former"))

    # Fetch data
    fetch_memberships_get <-
        httr::GET(url)
    fetch_current_memberships_get <-
        httr::GET(url_current)
    fetch_former_memberships_get <-
        httr::GET(url_former)

    fetch_memberships_output <-
        fetch_memberships(COMMITTEE_ID)
    fetch_memberships_output_summary <-
        fetch_memberships(COMMITTEE_ID, summary = FALSE)

    fetch_current_memberships_output <-
        fetch_current_memberships(COMMITTEE_ID)
    fetch_current_memberships_output_summary <-
        fetch_current_memberships(COMMITTEE_ID, summary = FALSE)

    fetch_former_memberships_output <-
        fetch_former_memberships(COMMITTEE_ID)
    fetch_former_memberships_output_summary <-
        fetch_former_memberships(COMMITTEE_ID, summary = FALSE)

    fetch_memberships_for_member_get <-
        httr::GET(url_for_member)
    fetch_current_memberships_for_member_get <-
        httr::GET(url_current_for_member)
    fetch_former_memberships_for_member_get <-
        httr::GET(url_former_for_member)

    fetch_memberships_for_member_output <-
        fetch_memberships_for_member(MEMBER_ID)
    fetch_memberships_for_member_output_summary <-
        fetch_memberships_for_member(MEMBER_ID, summary = FALSE)

    fetch_current_memberships_for_member_output <-
        fetch_current_memberships_for_member(MEMBER_ID)
    fetch_current_memberships_for_member_output_summary <-
        fetch_current_memberships_for_member(MEMBER_ID, summary = FALSE)

    fetch_former_memberships_for_member_output <-
        fetch_former_memberships_for_member(MEMBER_ID)
    fetch_former_memberships_for_member_output_summary <-
        fetch_former_memberships_for_member(MEMBER_ID, summary = FALSE)

    fetch_member_roles_output <-
        fetch_member_roles(COMMITTEE_ID)
    fetch_current_member_roles_output <-
        fetch_current_member_roles(COMMITTEE_ID)
    fetch_former_member_roles_output <-
        fetch_former_member_roles(COMMITTEE_ID)

    fetch_roles_for_member_output <-
        fetch_roles_for_member(MEMBER_ID)
    fetch_current_roles_for_member_output <-
        fetch_current_roles_for_member(MEMBER_ID)
    fetch_former_roles_for_member_output <-
        fetch_former_roles_for_member(MEMBER_ID)

    # Write data
    write_data(fetch_memberships_get,
        "fetch_memberships_get")
    write_data(fetch_current_memberships_get,
        "fetch_current_memberships_get")
    write_data(fetch_former_memberships_get,
        "fetch_former_memberships_get")

    write_data(fetch_memberships_output,
        "fetch_memberships_output")
    write_data(fetch_memberships_output_summary,
        "fetch_memberships_output_summary")

    write_data(fetch_current_memberships_output,
        "fetch_current_memberships_output")
    write_data(fetch_current_memberships_output_summary,
        "fetch_current_memberships_output_summary")

    write_data(fetch_former_memberships_output,
        "fetch_former_memberships_output")
    write_data(fetch_former_memberships_output_summary,
        "fetch_former_memberships_output_summary")

    write_data(fetch_memberships_for_member_get,
               "fetch_memberships_for_member_get")
    write_data(fetch_current_memberships_for_member_get,
               "fetch_current_memberships_for_member_get")
    write_data(fetch_former_memberships_for_member_get,
               "fetch_former_memberships_for_member_get")

    write_data(fetch_memberships_for_member_output,
        "fetch_memberships_for_member_output")
    write_data(fetch_memberships_for_member_output_summary,
        "fetch_memberships_for_member_output_summary")

    write_data(fetch_current_memberships_for_member_output,
        "fetch_current_memberships_for_member_output")
    write_data(fetch_current_memberships_for_member_output_summary,
        "fetch_current_memberships_for_member_output_summary")

    write_data(fetch_former_memberships_for_member_output,
        "fetch_former_memberships_for_member_output")
    write_data(fetch_former_memberships_for_member_output_summary,
        "fetch_former_memberships_for_member_output_summary")

    write_data(fetch_member_roles_output,
        "fetch_member_roles_output")
    write_data(fetch_current_member_roles_output,
        "fetch_current_member_roles_output")
    write_data(fetch_former_member_roles_output,
        "fetch_former_member_roles_output")

    write_data(fetch_roles_for_member_output,
        "fetch_roles_for_member_output")
    write_data(fetch_current_roles_for_member_output,
        "fetch_current_roles_for_member_output")
    write_data(fetch_former_roles_for_member_output,
        "fetch_former_roles_for_member_output")
}

# Fetch all memberships test data ---------------------------------------------

fetch_memberships_data()
message("API output recorded for memberships")
