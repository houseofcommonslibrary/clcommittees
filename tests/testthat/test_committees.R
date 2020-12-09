### Test committee functions
context("Committee functions")

# Imports ---------------------------------------------------------------------

source("data.R")

# Setup -----------------------------------------------------------------------

fetch_committees_get <-
    read_data("fetch_committees_get")

fetch_committees_get_current <-
    read_data("fetch_committees_get_current")

fetch_committees_get_former <-
    read_data("fetch_committees_get_former")

fetch_committees_output <-
    read_data("fetch_committees_output")
fetch_committees_output_summary <-
    read_data("fetch_committees_output_summary")

fetch_current_committees_output <-
    read_data("fetch_current_committees_output")
fetch_current_committees_output_summary <-
    read_data("fetch_current_committees_output_summary")

fetch_former_committees_output <-
    read_data("fetch_former_committees_output")
fetch_former_committees_output_summary <-
    read_data("fetch_former_committees_output_summary")

fetch_sub_committees_output <-
    read_data("fetch_sub_committees_output")
fetch_sub_committees_output_committees <-
    read_data("fetch_sub_committees_output_committees")

fetch_committee_types_output <-
    read_data("fetch_committee_types_output")
fetch_committee_types_output_committees <-
    read_data("fetch_committee_types_output_committees")

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

# Test fetch_current_committees -----------------------------------------------

test_that("fetch_current_committees returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get_current), {
            expected <- fetch_current_committees_output
            observed <- fetch_current_committees()
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_current_committees returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get_current), {
            expected <- fetch_current_committees_output_summary
            observed <- fetch_current_committees(summary = FALSE)
            expect_identical(observed, expected)
            expect_s3_class(observed$date_commons_appointed, "Date")
            expect_s3_class(observed$date_lords_appointed, "Date")
        })
})

# Test fetch_former_committees ------------------------------------------------

test_that("fetch_former_committees returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get_former), {
            expected <- fetch_former_committees_output
            observed <- fetch_former_committees()
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_former_committees returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_committees_get_former), {
            expected <- fetch_former_committees_output_summary
            observed <- fetch_former_committees(summary = FALSE)
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
            observed <- fetch_sub_committees(committees = COMMITTEE_ID)
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
            observed <- fetch_committee_types(committees = COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})
