### Request functions for fetching and processing data

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

    # Convert response text to json
    response_json <- response_text %>%
        jsonlite::fromJSON(flatten = TRUE)

    # Warn if the number of items available is greater than the maximum taken
    if ("totalResults" %in% names(response_json)) {
        if (response_json$totalResults > as.integer(PARAMETER_TAKE_THRESHOLD)) {
            warning(stringr::str_c(
                "The number of items available is greater than ",
                "the maximum number of items taken."))
        }
    }

    response_json
}

#' Get the data items from an API response as a tibble
#'
#' @param response The response returned from a call to \code{request}.
#' @export

get_response_items <- function(response) {
    # Extract items as a tibble and clean names
    response$items %>%
        tibble::as_tibble() %>%
        janitor::clean_names()
}

#' Send a request to API and return the response items as a tibble
#'
#' \code{request_items} makes an API call to the given endpoint, converts the
#' response to a tibble, and cleans the column names.
#'
#' @param url The full API URL specifying the endpoint and request parameters.
#' @export

request_items <- function(url) {
    get_response_items(request(url))
}
