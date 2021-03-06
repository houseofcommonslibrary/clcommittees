% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/memberships.R
\name{fetch_current_roles_for_member}
\alias{fetch_current_roles_for_member}
\title{Fetch data on the current committee roles of a given member}
\usage{
fetch_current_roles_for_member(member)
}
\arguments{
\item{member}{An integer representing the mnis_id of the member for which to
fetch the current roles.}
}
\description{
\code{fetch_current_roles_for_member} fetches data on the current committee
roles of a given member and returns it as a tibble containing one row per
committee role.
}
\details{
A role indicates a period of service in a given position, so this function
returns the member's the current roles. A role without an end date is a
current role.

A member may have concurrent roles for the same period reflecting different
positions e.g. one indicating their service as a member and another their
service as a chair.
}
