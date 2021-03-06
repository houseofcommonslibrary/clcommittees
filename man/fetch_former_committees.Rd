% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/committees.R
\name{fetch_former_committees}
\alias{fetch_former_committees}
\title{Fetch data on former committees as a tibble}
\usage{
fetch_former_committees(summary = TRUE)
}
\arguments{
\item{summary}{A boolean indicating whether to exclude nested and empty
columns in the results. The default is TRUE.}
}
\description{
\code{fetch_former_committees} fetches data on foremr committees and
returns it as a tibble containing one row per committee. Former committees
are those that have an end date.
}
\details{
By default this function returns a subset of the columns and ignores any
nested and redundant columns. Set \code{summary = FALSE} when calling the
function to retrieve the full data.
}
