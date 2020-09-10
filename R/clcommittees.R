#' clcommittees: Tools for retreiving data from the Committees Information
#' System API
#'
#' The clcommittees package provides a suit of tools for downloading and
#' processing data from the UK Parliament's Committees Information System API.
#'
#' @docType package
#' @name clcommittees
#' @importFrom magrittr %>%
#' @importFrom rlang .data
NULL

# Tell R CMD check about new operators
if(getRversion() >= "2.15.1") {
    utils::globalVariables(c(".", ":="))
}
