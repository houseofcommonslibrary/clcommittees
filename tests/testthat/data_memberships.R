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

    url_current <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/{COMMITTEE_ID}/membership/current?",
        "parameters.all=true"
    ))

    url_former <- stringr::str_glue(stringr::str_c(
        "https://committees-api.parliament.uk/",
        "committees/{COMMITTEE_ID}/membership/former?",
        "parameters.all=true"
    ))

    # Fetch data
    fetch_current_members_get <- httr::GET(url_current)
    fetch_former_members_get <- httr::GET(url_former)

    fetch_current_members_output <- fetch_current_members(COMMITTEE_ID)
    fetch_current_members_output_summary <- fetch_current_members(
        COMMITTEE_ID, summary = FALSE)

    fetch_former_members_output <- fetch_former_members(COMMITTEE_ID)
    fetch_former_members_output_summary <- fetch_former_members(
        COMMITTEE_ID, summary = FALSE)

    fetch_all_members_output <- fetch_all_members(COMMITTEE_ID)
    fetch_all_members_output_summary <- fetch_all_members(
        COMMITTEE_ID, summary = FALSE)

    fetch_current_roles_output <- fetch_current_roles(COMMITTEE_ID)
    fetch_former_roles_output <- fetch_former_roles(COMMITTEE_ID)
    fetch_all_roles_output <- fetch_all_roles(COMMITTEE_ID)

    # Write data
    write_data(fetch_current_members_get, "fetch_current_members_get")
    write_data(fetch_former_members_get, "fetch_former_members_get")

    write_data(fetch_current_members_output, "fetch_current_members_output")
    write_data(fetch_current_members_output_summary, "fetch_current_members_output_summary")

    write_data(fetch_former_members_output, "fetch_former_members_output")
    write_data(fetch_former_members_output_summary, "fetch_former_members_output_summary")

    write_data(fetch_all_members_output, "fetch_all_members_output")
    write_data(fetch_all_members_output_summary, "fetch_all_members_output_summary")

    write_data(fetch_current_roles_output, "fetch_current_roles_output")
    write_data(fetch_former_roles_output, "fetch_former_roles_output")
    write_data(fetch_all_roles_output, "fetch_all_roles_output")
}

# Fetch all memberships test data ---------------------------------------------

fetch_memberships_data()
message("API output recorded for memberships")
