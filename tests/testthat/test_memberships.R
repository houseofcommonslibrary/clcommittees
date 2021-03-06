### Test committee functions
context("Membership functions")

# Imports ---------------------------------------------------------------------

source("data.R")

# Setup -----------------------------------------------------------------------

fetch_committees_get <-
    read_data("fetch_committees_get")
fetch_memberships_get <-
    read_data("fetch_memberships_get")
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

fetch_member_roles_output <-
    read_data("fetch_member_roles_output")
fetch_current_member_roles_output <-
    read_data("fetch_current_member_roles_output")
fetch_former_member_roles_output <-
    read_data("fetch_former_member_roles_output")

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

mock_fetch_memberships <- function(committee_id, summary = TRUE) {
    if (summary == TRUE){
        fetch_memberships_output
    } else {
        fetch_memberships_output_summary
    }
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

mock_fetch_memberships_get <- function(url) {

    committees_url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees?Take={PARAMETER_TAKE_THRESHOLD}",
        "&CommitteeStatus=All"))

    memberships_url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees/{COMMITTEE_ID}/Members?",
        "Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=All"))

    if (url == committees_url) {
        return(fetch_committees_get)
    }

    if (url == memberships_url) {
        return(fetch_memberships_get)
    }
}

mock_fetch_current_memberships_get <- function(url) {

    committees_url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees?Take={PARAMETER_TAKE_THRESHOLD}",
        "&CommitteeStatus=All"))

    memberships_url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees/{COMMITTEE_ID}/Members?",
        "Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Current"))

    if (url == committees_url) {
        return(fetch_committees_get)
    }

    if (url == memberships_url) {
        return(fetch_current_memberships_get)
    }
}

mock_fetch_former_memberships_get <- function(url) {

    committees_url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees?Take={PARAMETER_TAKE_THRESHOLD}",
        "&CommitteeStatus=All"))

    memberships_url <- stringr::str_glue(stringr::str_c(
        API_BASE_URL,
        "Committees/{COMMITTEE_ID}/Members?",
        "Take={PARAMETER_TAKE_THRESHOLD}",
        "&MembershipStatus=Former"))

    if (url == committees_url) {
        return(fetch_committees_get)
    }

    if (url == memberships_url) {
        return(fetch_former_memberships_get)
    }
}

# Test fetch_memberships ------------------------------------------------------

test_that("fetch_memberships returns expected data", {
    with_mock(
        "httr::GET" = mock_fetch_memberships_get, {
            expected <- fetch_memberships_output
            observed <- fetch_memberships(COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_memberships returns the full table", {
    with_mock(
        "httr::GET" = mock_fetch_memberships_get, {
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
        regexp = "The committee_id argument must be a single committee id")
})

# Test fetch_current_memberships ----------------------------------------------

test_that("fetch_current_memberships returns expected data", {
    with_mock(
        "httr::GET" = mock_fetch_current_memberships_get, {
            expected <- fetch_current_memberships_output
            observed <- fetch_current_memberships(COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_current_memberships returns the full table", {
    with_mock(
        "httr::GET" = mock_fetch_current_memberships_get, {
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

test_that("fetch_current_memberships throws an error for more than one committee id", {
    expect_error(
        fetch_current_memberships(rep(COMMITTEE_ID, 2)),
        regexp = "The committee_id argument must be a single committee id")
})

# Test fetch_former_memberships -----------------------------------------------

test_that("fetch_former_memberships returns expected data", {
    with_mock(
        "httr::GET" = mock_fetch_former_memberships_get, {
            expected <- fetch_former_memberships_output
            observed <- fetch_former_memberships(COMMITTEE_ID)
            expect_identical(observed, expected)
        })
})

test_that("fetch_former_memberships returns the full table", {
    with_mock(
        "httr::GET" = mock_fetch_former_memberships_get, {
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

test_that("fetch_former_memberships throws an error for more than one committee id", {
    expect_error(
        fetch_former_memberships(rep(COMMITTEE_ID, 2)),
        regexp = "The committee_id argument must be a single committee id")
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

# Test fetch_member_roles -----------------------------------------------------

test_that("fetch_member_roles returns expected data", {
    with_mock(
        "fetch_memberships" = mock_fetch_memberships, {
            expected <- fetch_member_roles_output
            observed <- fetch_member_roles(COMMITTEE_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_member_roles returns an empty tibble for a non-existent committee", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_member_roles(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_current_member_roles ---------------------------------------------

test_that("fetch_current_member_roles returns expected data", {
    with_mock(
        "fetch_current_memberships" = mock_fetch_current_memberships, {
            expected <- fetch_current_member_roles_output
            observed <- fetch_current_member_roles(COMMITTEE_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_current_member_roles returns an empty tibble for a non-existent committee", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_current_member_roles(-1)
            expect_identical(observed, expected)
        })
})

# Test fetch_former_roles -----------------------------------------------------

test_that("fetch_former_member_roles returns expected data", {
    with_mock(
        "fetch_former_memberships" = mock_fetch_former_memberships, {
            expected <- fetch_former_member_roles_output
            observed <- fetch_former_member_roles(COMMITTEE_ID)
            expect_identical(observed, expected)
            expect_s3_class(observed$start_date, "Date")
            expect_s3_class(observed$end_date, "Date")
        })
})

test_that("fetch_former_member_roles returns an empty tibble for a non-existent committee", {
    with_mock(
        "request_items" = mock_request_items, {
            expected <- tibble::tibble()
            observed <- fetch_former_member_roles(-1)
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
