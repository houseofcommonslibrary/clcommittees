### Test commiittee functions
context("Committee functions")

# Imports ---------------------------------------------------------------------

source("data.R")

# Setup -----------------------------------------------------------------------

url <- stringr::str_c(
    "https://committees-api.parliament.uk/committees?",
    "parameters.all=true&",
    "parameters.currentOnly=false")

fetch_committees_get <- read_data("fetch_committees_get")

fetch_committees_output <- read_data("fetch_committees_output")
fetch_committees_output_current <- read_data("fetch_committees_output_current")
fetch_committees_output_summary <- read_data("fetch_committees_output_summary")

fetch_sub_committees_output <- read_data("fetch_sub_committees_output")
fetch_sub_committees_output_committees <- read_data("fetch_sub_committees_output_committees")
fetch_sub_committees_output_current <- read_data("fetch_sub_committees_output_current")

fetch_current_chairs_output <- read_data("fetch_current_chairs_output")
fetch_current_chairs_output_committees <- read_data("fetch_current_chairs_output_committees")
fetch_current_chairs_output_summary <- read_data("fetch_current_chairs_output_summary")

fetch_committee_types_output <- read_data("fetch_committee_types_output")
fetch_committee_types_output_committees <- read_data("fetch_committee_types_output_committees")
fetch_committee_types_output_current <- read_data("fetch_committee_types_output_current")

# Test fetch_committees -------------------------------------------------------

test_that("fetch_committees returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_committees_output
            observed <- fetch_committees()
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_committees returns only current committees", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_committees_output_current
            observed <- fetch_committees(current = TRUE)
            expect_identical(observed, expected)
        })
})

test_that("fetch_committees returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_committees_output_summary
            observed <- fetch_committees(summary = FALSE)
            expect_identical(observed, expected)
            expect_s3_class(observed$date_commons_appointed, "Date")
            expect_s3_class(observed$date_lords_appointed, "Date")
        })
})

# Test fetch_sub_committees ---------------------------------------------------

test_that("fetch_sub_committees returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_sub_committees_output
            observed <- fetch_sub_committees()
            expect_identical(observed, expected)
        })
})

test_that("fetch_sub_committees returns data for expected committees", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_sub_committees_output_committees
            observed <- fetch_sub_committees(committees = 176)
            expect_identical(observed, expected)
        })
})

test_that("fetch_sub_committees returns data for only current committees", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_sub_committees_output_current
            observed <- fetch_sub_committees(current = TRUE)
            expect_identical(observed, expected)
        })
})

# Test fetch_current_chairs ---------------------------------------------------

test_that("fetch_current_chairs returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_current_chairs_output
            observed <- fetch_current_chairs()
            expect_identical(observed, expected)
        })
})

test_that("fetch_current_chairs returns data for expected committees", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_current_chairs_output_committees
            observed <- fetch_current_chairs(committees = 176)
            expect_identical(observed, expected)
        })
})

test_that("fetch_current_chairs returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_current_chairs_output_summary
            observed <- fetch_current_chairs(summary = FALSE)
            expect_identical(observed, expected)
        })
})

# Test fetch_committee_types --------------------------------------------------

test_that("fetch_committee_types returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_committee_types_output
            observed <- fetch_committee_types()
            expect_identical(observed, expected)
        })
})

test_that("fetch_committee_types returns data for expected committees", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_committee_types_output_committees
            observed <- fetch_committee_types(committees = 176)
            expect_identical(observed, expected)
        })
})

test_that("fetch_committee_types returns data for only current committees", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get), {
            expected <- fetch_committee_types_output_current
            observed <- fetch_committee_types(current = TRUE)
            expect_identical(observed, expected)
        })
})
