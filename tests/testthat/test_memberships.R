### Test committee functions
context("Membership functions")

# Imports ---------------------------------------------------------------------

source("data.R")

# Setup -----------------------------------------------------------------------

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

fetch_current_members_get <- read_data("fetch_current_members_get")
fetch_former_members_get <- read_data("fetch_former_members_get")

fetch_current_members_output <- read_data("fetch_current_members_output")
fetch_current_members_output_summary <- read_data("fetch_current_members_output_summary")

fetch_former_members_output <- read_data("fetch_former_members_output")
fetch_former_members_output_summary <- read_data("fetch_former_members_output_summary")

fetch_all_members_output <- read_data("fetch_all_members_output")
fetch_all_members_output_summary <- read_data("fetch_all_members_output_summary")

fetch_current_roles_output <- read_data("fetch_current_roles_output")
fetch_former_roles_output <- read_data("fetch_former_roles_output")
fetch_all_roles_output <- read_data("fetch_all_roles_output")

# Mocks -----------------------------------------------------------------------

mock_fetch_current_members <- function(committee_id, summary = TRUE) {
    if (summary == TRUE){
        fetch_current_members_output
    } else {
        fetch_current_members_output_summary
    }
}

mock_fetch_former_members <- function(committee_id, summary = TRUE) {
    if (summary == TRUE){
        fetch_former_members_output
    } else {
        fetch_former_members_output_summary
    }
}

# Test fetch_current_members --------------------------------------------------

test_that("fetch_current_members returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_current_members_get), {
            expected <- fetch_current_members_output
            observed <- fetch_current_members(COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_current_members returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_current_members_get), {
            expected <- fetch_current_members_output_summary
            observed <- fetch_current_members(COMMITTEE_ID, summary = FALSE)
            expect_identical(observed, expected)
        })
})

# Test fetch_former_members ---------------------------------------------------

test_that("fetch_former_members returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_former_members_get), {
            expected <- fetch_former_members_output
            observed <- fetch_former_members(COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_former_members returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_former_members_get), {
            expected <- fetch_former_members_output_summary
            observed <- fetch_former_members(COMMITTEE_ID, summary = FALSE)
            expect_identical(observed, expected)
        })
})

# Test fetch_all_members ------------------------------------------------------

test_that("fetch_all_members returns expected data", {
    with_mock(
        "fetch_current_members" = mock_fetch_current_members,
        "fetch_former_members" = mock_fetch_former_members, {
            expected <- fetch_all_members_output
            observed <- fetch_all_members(COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_all_members returns the full table", {
    with_mock(
        "fetch_current_members" = mock_fetch_current_members,
        "fetch_former_members" = mock_fetch_former_members, {
            expected <- fetch_all_members_output_summary
            observed <- fetch_all_members(COMMITTEE_ID, summary = FALSE)
            expect_identical(observed, expected)
        })
})

# Test fetch_current_roles ----------------------------------------------------

test_that("fetch_current_roles returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_current_members_get), {
            expected <- fetch_current_roles_output
            observed <- fetch_current_roles(COMMITTEE_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

# Test fetch_former_roles ----------------------------------------------------

test_that("fetch_former_roles returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_former_members_get), {
            expected <- fetch_former_roles_output
            observed <- fetch_former_roles(COMMITTEE_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

# Test fetch_all_roles ----------------------------------------------------

test_that("fetch_all_roles returns expected data", {
    with_mock(
        "fetch_current_members" = mock_fetch_current_members,
        "fetch_former_members" = mock_fetch_former_members, {
            expected <- fetch_all_roles_output
            observed <- fetch_all_roles(COMMITTEE_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})
