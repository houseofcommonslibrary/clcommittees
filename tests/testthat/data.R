### Record and retrieve test data: helper functions

# About -----------------------------------------------------------------------

# The functions in this file are used to record the output of the api and the
# functions that process that data in order to produce mocks, and to check if
# the expected behaviour of the functions has changed. The file paths are set
# in here so that you can source files for creating test data from within the
# package project during development, and source the test data files from
# within the tests.

# Constants -------------------------------------------------------------------

READ_TEST_DIR <- file.path("data")
WRITE_TEST_DIR <- file.path("tests", "testthat", "data")
COMMITTEE_ID <- 176
MEMBER_ID <- 172
ENDPOINT_URL <- stringr::str_c(
    "https://committees-api.parliament.uk/committees?",
    "parameters.all=true&",
    "parameters.currentOnly=false")

# Read and write data ---------------------------------------------------------

# Read a file from the data directory
read_data <- function(filename) {
    readRDS(file.path(READ_TEST_DIR,
                      stringr::str_glue("{filename}.RData")))
}

# Write R data to the data directory
write_data <- function(data, filename) {
    saveRDS(data, file.path(WRITE_TEST_DIR,
                          stringr::str_glue("{filename}.RData")))
}

# Mocks -----------------------------------------------------------------------

# Mocks a call to httr::GET which returns the given response
get_mock_get <- function(response) {
    function(url) {response}
}


