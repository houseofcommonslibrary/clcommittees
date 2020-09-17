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

url_for_member <- stringr::str_glue(stringr::str_c(
    "https://committees-api.parliament.uk/",
    "committees/membership/member?",
    "parameters.members={MEMBER_ID}"
))

url_current_for_member <- stringr::str_glue(stringr::str_c(
    "https://committees-api.parliament.uk/",
    "committees/membership/member?",
    "parameters.former=false&parameters.members={MEMBER_ID}"
))

url_former_for_member <- stringr::str_glue(stringr::str_c(
    "https://committees-api.parliament.uk/",
    "committees/membership/member?",
    "parameters.former=true&parameters.members={MEMBER_ID}"
))

fetch_current_memberships_get <-
    read_data("fetch_current_memberships_get")
fetch_former_memberships_get <-
    read_data("fetch_former_memberships_get")

fetch_memberships_output <-
    read_data("fetch_memberships_output")
fetch_memberships_output_summary <-
    read_data("fetch_memberships_output_summary")

fetch_current_memberships_output <-
    read_data("fetch_current_memberships_output")
fetch_current_memberships_output_summary <-
    read_data("fetch_current_memberships_output_summary")

fetch_former_memberships_output <-
    read_data("fetch_former_memberships_output")
fetch_former_memberships_output_summary <-
    read_data("fetch_former_memberships_output_summary")


fetch_memberships_for_member_get <-
    read_data("fetch_memberships_for_member_get")
fetch_current_memberships_for_member_get <-
    read_data("fetch_current_memberships_for_member_get")
fetch_former_memberships_for_member_get <-
    read_data("fetch_former_memberships_for_member_get")

fetch_memberships_for_member_output <-
    read_data("fetch_memberships_for_member_output")
fetch_memberships_for_member_output_summary <-
    read_data("fetch_memberships_for_member_output_summary")

fetch_current_memberships_for_member_output <-
    read_data("fetch_current_memberships_for_member_output")
fetch_current_memberships_for_member_output_summary <-
    read_data("fetch_current_memberships_for_member_output_summary")

fetch_former_memberships_for_member_output <-
    read_data("fetch_former_memberships_for_member_output")
fetch_former_memberships_for_member_output_summary <-
    read_data("fetch_former_memberships_for_member_output_summary")


fetch_roles_output <-
    read_data("fetch_roles_output")
fetch_current_roles_output <-
    read_data("fetch_current_roles_output")
fetch_former_roles_output <-
    read_data("fetch_former_roles_output")


fetch_roles_for_member_output <-
    read_data("fetch_roles_for_member_output")
fetch_current_roles_for_member_output <-
    read_data("fetch_current_roles_for_member_output")
fetch_former_roles_for_member_output <-
    read_data("fetch_former_roles_for_member_output")

# Mocks -----------------------------------------------------------------------

mock_request_items <- function(url) {
    tibble::tibble()
}

mock_fetch_current_memberships <- function(committee_id, summary = TRUE) {
    if (summary == TRUE){
        fetch_current_memberships_output
    } else {
        fetch_current_memberships_output_summary
    }
}

mock_fetch_former_memberships <- function(committee_id, summary = TRUE) {
    if (summary == TRUE){
        fetch_former_memberships_output
    } else {
        fetch_former_memberships_output_summary
    }
}

# Test fetch_memberships ------------------------------------------------------

test_that("fetch_memberships returns expected data", {
    with_mock(
        "fetch_current_memberships" = mock_fetch_current_memberships,
        "fetch_former_memberships" = mock_fetch_former_memberships, {
            expected <- fetch_memberships_output
            observed <- fetch_memberships(COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_memberships returns the full table", {
    with_mock(
        "fetch_current_memberships" = mock_fetch_current_memberships,
        "fetch_former_memberships" = mock_fetch_former_memberships, {
            expected <- fetch_memberships_output_summary
            observed <- fetch_memberships(
                COMMITTEE_ID, summary = FALSE)
            expect_identical(observed, expected)
        })
})

test_that("fetch_memberships returns an empty tibble for a non-existent committee", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_memberships(-1)
            expect_identical(observed, expected)
        })
})

test_that("fetch_memberships throws an error for more than one committee id", {
    expect_error(
        fetch_memberships(rep(COMMITTEE_ID, 2)),
        regexp = "The committee argument must be a single committee id")

})

# Test fetch_current_memberships ----------------------------------------------

test_that("fetch_current_memberships returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_current_memberships_get), {
            expected <- fetch_current_memberships_output
            observed <- fetch_current_memberships(COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_current_memberships returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_current_memberships_get), {
            expected <- fetch_current_memberships_output_summary
            observed <- fetch_current_memberships(
                COMMITTEE_ID, summary = FALSE)
            expect_identical(observed, expected)
        })
})

test_that("fetch_current_memberships returns an empty tibble for a non-existent committee", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_current_memberships(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_former_memberships -----------------------------------------------

test_that("fetch_former_memberships returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_former_memberships_get), {
            expected <- fetch_former_memberships_output
            observed <- fetch_former_memberships(COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_former_memberships returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_former_memberships_get), {
            expected <- fetch_former_memberships_output_summary
            observed <- fetch_former_memberships(
                COMMITTEE_ID, summary = FALSE)
            expect_identical(observed, expected)
        })
})

test_that("fetch_former_memberships returns an empty tibble for a non-existent committee", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_former_memberships(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_memberships_for_member -------------------------------------------

test_that("fetch_memberships_for_member returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_memberships_for_member_get), {
            expected <- fetch_memberships_for_member_output
            observed <- fetch_memberships_for_member(MEMBER_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_memberships_for_member returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_memberships_for_member_get), {
            expected <- fetch_memberships_for_member_output_summary
            observed <- fetch_memberships_for_member(
                MEMBER_ID, summary = FALSE)
            expect_identical(observed, expected)
        })
})

test_that("fetch_memberships_for_member returns an empty tibble for a non-existent member", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_memberships_for_member(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_current_memberships_for_member -----------------------------------

test_that("fetch_current_memberships_for_member returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_current_memberships_for_member_get), {
            expected <- fetch_current_memberships_for_member_output
            observed <- fetch_current_memberships_for_member(MEMBER_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_current_memberships_for_member returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_current_memberships_for_member_get), {
            expected <- fetch_current_memberships_for_member_output_summary
            observed <- fetch_current_memberships_for_member(
                MEMBER_ID, summary = FALSE)
            expect_identical(observed, expected)
        })
})

test_that("fetch_current_memberships_for_member returns an empty tibble for a non-existent member", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_current_memberships_for_member(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_former_memberships_for_member ------------------------------------

test_that("fetch_former_memberships_for_member returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_former_memberships_for_member_get), {
            expected <- fetch_former_memberships_for_member_output
            observed <- fetch_former_memberships_for_member(MEMBER_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_former_memberships_for_member returns the full table", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_former_memberships_for_member_get), {
            expected <- fetch_former_memberships_for_member_output_summary
            observed <- fetch_former_memberships_for_member(
                MEMBER_ID, summary = FALSE)
            expect_identical(observed, expected)
        })
})

test_that("fetch_former_memberships_for_member returns an empty tibble for a non-existent member", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_former_memberships_for_member(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_roles ------------------------------------------------------------

test_that("fetch_roles returns expected data", {
    with_mock(
        "fetch_current_memberships" = mock_fetch_current_memberships,
        "fetch_former_memberships" = mock_fetch_former_memberships, {
            expected <- fetch_roles_output
            observed <- fetch_roles(COMMITTEE_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_roles returns an empty tibble for a non-existent committee", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_roles(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_current_roles ----------------------------------------------------

test_that("fetch_current_roles returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_current_memberships_get), {
            expected <- fetch_current_roles_output
            observed <- fetch_current_roles(COMMITTEE_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_current_roles returns an empty tibble for a non-existent committee", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_current_roles(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_former_roles -----------------------------------------------------

test_that("fetch_former_roles returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_former_memberships_get), {
            expected <- fetch_former_roles_output
            observed <- fetch_former_roles(COMMITTEE_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_former_roles returns an empty tibble for a non-existent committee", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_former_roles(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_roles_for_member -------------------------------------------------

test_that("fetch_roles_for_member returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_memberships_for_member_get), {
            expected <- fetch_roles_for_member_output
            observed <- fetch_roles_for_member(MEMBER_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_roles_for_member returns an empty tibble for a non-existent member", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_roles_for_member(-1)
            expect_identical(observed, expected)
        })
})


# Test fetch_current_roles_for_member -----------------------------------------

test_that("fetch_current_roles_for_member returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_current_memberships_for_member_get), {
            expected <- fetch_current_roles_for_member_output
            observed <- fetch_current_roles_for_member(MEMBER_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_current_roles_for_member returns an empty tibble for a non-existent member", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_current_roles_for_member(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_former_roles_for_member ------------------------------------------

test_that("fetch_former_roles_for_member returns expected data", {
    with_mock(
        "httr::GET" = get_mock_get(fetch_former_memberships_for_member_get), {
            expected <- fetch_former_roles_for_member_output
            observed <- fetch_former_roles_for_member(MEMBER_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_former_roles_for_member returns an empty tibble for a non-existent member", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_former_roles_for_member(-1)
            expect_identical(observed, expected)
        })
})
