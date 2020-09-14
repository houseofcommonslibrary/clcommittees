### Test core functions
context("Core functions")

# Imports ---------------------------------------------------------------------

source("data.R")

# Setup -----------------------------------------------------------------------

url <- stringr::str_c(
    "https://committees-api.parliament.uk/committees?",
    "parameters.all=true&",
    "parameters.currentOnly=false")

request_get <- read_data("request_get")
request_output <- read_data("request_output")
get_response_items_output <- read_data("get_response_items_output")
request_items_output <- read_data("request_items_output")

# Test request ----------------------------------------------------------------

test_that("request processes an http response for a valid GET request", {
    with_mock(
        "httr::GET" = get_mock_get(request_get), {
            expected <- request_output
            observed <- request(url)
            expect_identical(observed, expected)
        })
})

test_that("request throws an error when http status is not 200", {
    with_mock(
        "httr::GET" = get_mock_get(request_get), {
            request_get$status_code <- 500
            expect_error(
                request(url),
                regexp = "The server responded with the following message: ")
        })
})

# Test get_response_items -----------------------------------------------------

test_that("get_response_items extracts the items as a tibble", {
    with_mock(
        "httr::GET" = get_mock_get(request_get), {
            expected <- get_response_items_output
            observed <- get_response_items(request(url))
            expect_identical(observed, expected)
        })
})

# Test request_items -----------------------------------------------------

test_that("request_items requests and extracts item data correctly", {
    with_mock(
        "httr::GET" = get_mock_get(request_get), {
            expected <- request_items_output
            observed <- request_items(url)
            expect_identical(observed, expected)
        })
})
