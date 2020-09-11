### Record and retrieve test data: committee functions

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

fetch_committees_data <- function() {

    url <- stringr::str_c(
        "https://committees-api.parliament.uk/committees?",
        "parameters.all=true&",
        "parameters.currentOnly=false")

    # Fetch data
    fetch_committees_get <- httr::GET(url)

    fetch_committees_output <- fetch_committees()
    fetch_committees_output_current <- fetch_committees(current = TRUE)
    fetch_committees_output_summary <- fetch_committees(summary = FALSE)

    fetch_sub_committees_output <- fetch_sub_committees()
    fetch_sub_committees_output_committees <- fetch_sub_committees(committees = COMMITTEE_ID)
    fetch_sub_committees_output_current <- fetch_sub_committees(current = TRUE)

    fetch_committee_types_output <- fetch_committee_types()
    fetch_committee_types_output_committees <- fetch_committee_types(committees = COMMITTEE_ID)
    fetch_committee_types_output_current <- fetch_committee_types(current = TRUE)

    fetch_current_chairs_output <- fetch_current_chairs()
    fetch_current_chairs_output_committees <- fetch_current_chairs(committees = COMMITTEE_ID)
    fetch_current_chairs_output_summary <- fetch_current_chairs(summary = FALSE)

    # Write data
    write_data(fetch_committees_get, "fetch_committees_get")

    write_data(fetch_committees_output, "fetch_committees_output")
    write_data(fetch_committees_output_current, "fetch_committees_output_current")
    write_data(fetch_committees_output_summary, "fetch_committees_output_summary")

    write_data(fetch_sub_committees_output, "fetch_sub_committees_output")
    write_data(fetch_sub_committees_output_committees, "fetch_sub_committees_output_committees")
    write_data(fetch_sub_committees_output_current, "fetch_sub_committees_output_current")

    write_data(fetch_committee_types_output, "fetch_committee_types_output")
    write_data(fetch_committee_types_output_committees, "fetch_committee_types_output_committees")
    write_data(fetch_committee_types_output_current, "fetch_committee_types_output_current")

    write_data(fetch_current_chairs_output, "fetch_current_chairs_output")
    write_data(fetch_current_chairs_output_committees, "fetch_current_chairs_output_committees")
    write_data(fetch_current_chairs_output_summary, "fetch_current_chairs_output_summary")
}

# Fetch all committees test data ----------------------------------------------

fetch_committees_data()
message("API output recorded for committees")
