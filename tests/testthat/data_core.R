### Record and retrieve test data: core functions

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

fetch_core_data <- function() {

    url <- stringr::str_c(
        "https://committees-api.parliament.uk/committees?",
        "parameters.all=true&",
        "parameters.currentOnly=false")

    request_get <- httr::GET(url)
    request_output <- request(url)
    get_response_items_output <- get_response_items(request_output)
    request_items_output <- get_response_items_output

    write_data(request_get, "request_get")
    write_data(request_output, "request_output")
    write_data(get_response_items_output, "get_response_items_output")
    write_data(request_items_output, "request_items_output")
}

# Fetch all core test data ----------------------------------------------------

fetch_core_data()
message("API output recorded for core")
