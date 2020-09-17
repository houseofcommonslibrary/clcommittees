### Core functions for fetching and processing data

#' Send a request to API and return the response as a named list
#'
#' @param url The full API URL specifying the endpoint and request parameters.
#' @export

request <- function(url) {

    # Get the raw data from the given URL endpoint
    response <- httr::GET(url)

    # Parse the response
    response_text <- httr::content(response, as = "text", encoding = "utf-8")

    # If the server returned an error raise it with the response text
    if (response$status_code != 200) stop(request_error(response_text))

    response_text %>%
        jsonlite::fromJSON(flatten = TRUE)
}

#' Get the data items from an API response as a tibble
#'
#' @param response The response returned from a call to \code{request}.
#' @export

get_response_items <- function(response) {
    # Extract items as a tibble and clean names
    response$items %>%
        tibble::as_tibble() %>%
        clean_column_names("value")
}

#' Send a request to API and return the response items as a tibble
#'
#' \code{request_items} makes an API call to the given endpoint, extracts
#' the data items from the response as a tibble, and cleans the column names.
#' Do not use this function if you need to access any of the other properties
#' of the response object; call \code{request} and \code{get_response_items}
#' separately.
#'
#' @param url The full API URL specifying the endpoint and request parameters.
#' @export

request_items <- function(url) {
    get_response_items(request(url))
}
