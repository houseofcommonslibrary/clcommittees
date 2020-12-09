# clcommittees

clcommittees is an R package for downloading data from the UK Parliament's [Committees API](https://committees-api.parliament.uk/). This package has been developed principally to support work on Parliamentary data in the House of Commons Library but it may be useful to other researchers working with this data. This package is still in active development and the API may evolve over time.

## Version 0.2.0

On 9 December 2020, the Parliamentary Digital Service launched a new version of the Committees API. The new version introduced substantial changes to the API endpoints and parameters.

Since version 0.2.0, clcommittees has been updated to use the new version of the Committees API. This version of the package aims to provide equivalent information to the previous version but it unavoidably contains breaking changes. The functions themselves have similar names and signatures to those they replace, but the structure of the data they return is different. It is likely that you will need to accomodate these changes in any code that uses this package.

## Overview

The package provides sets of functions for retrieving data from different endpoints of the Committees API and returning the data as a tibble. The package currently provides functions to download data from the `Committees` and `Members` endpoints, but new functions may be added to extract data from other endpoints in future. The package does not aim to exhaustively expose every possible API parameter for a given endpoint, but is focussed on downloading key datasets than can be further explored, transformed and combined with other data in R. To help with using parts of the API that are not explicitly covered, the package also provides some lower level functions that allow you to retrieve data from API endpoints as native R data structures. 

## Installation

Install from GitHub using remotes.

``` r
install.packages("remotes")
remotes::install_github("houseofcommonslibrary/clcommittees")
```

## Contents

* [Committees](https://github.com/houseofcommonslibrary/clcommittees#committees)
* [Committee Memberships](https://github.com/houseofcommonslibrary/clcommittees#committee-memberships)
* [Committee Roles](https://github.com/houseofcommonslibrary/clcommittees#committee-roles)
* [Requests](https://github.com/houseofcommonslibrary/clcommittees#requests)


## Committees

Functions to download data on committees.

---

_clcommittees_::__fetch_committees__(_summary = TRUE_)  
_clcommittees_::__fetch_current_committees__(_summary = TRUE_)  
_clcommittees_::__fetch_former_committees__(_summary = TRUE_)  

Fetch data on current and former committees and return it as a tibble containing one row per committee. `fetch_committees` returns data on both the current and former committees, while `fetch_current_committees` and `fetch_former_committees` return the current and former committees respectively. 

The `summary` argument is a boolean indicating whether to return a summary of key data or the full tibble. Setting `summary` to `TRUE` removes list columns and empty columns from the result. Data held in the list columns for this dataset, such as data on subcommittees, committee types, and scrutinising departments can be more easily extracted with one of the other functions shown below.

---

_clcommittees_::__fetch_sub_committees__(_committees = NULL_, _summary = TRUE_)  

Fetch data on the subcommittees of parent comittees and return it as a tibble containing one row per combination of parent and subcommittee. The data returned for each subcommittee is the data from the `sub_committees` table of its parent committee in the full table returned from the `fetch_committees` functions.

You can optionally use the `committees` argument to provide a vector of committee ids to return just the subcommittees of the given parent committees. Any committee that is a subcommittee will also be listed as a committee in the table returned from `fetch_committees` functions, so you may wish to use the results of `fetch_sub_committees` to filter the results of those functions.

The `summary` argument is a boolean indicating whether to return a summary of key data or the full tibble. Setting `summary` to `TRUE` removes list columns and empty columns from the result.

---

_clcommittees_::__fetch_committee_types__(_committees = NULL_)  

Fetch data on the types of comittees and return it as a tibble containing one row per combination of committee and type. The data returned for each type is the data from the `committee_types` table of the committee in the full table returned from the `fetch_committees` functions.

You can optionally use the `committees` argument to provide a vector of committee ids to return just the types of the given committees.

---

_clcommittees_::__fetch_scrutinising_departments__(_committees = NULL_)  

Fetch data on the government departments scrutisinised by comittees and return it as a tibble containing one row per combination of committee and department. The data returned for each department is the data from the `scrutinising_departments` table of the committee in the full table returned from the `fetch_committees` functions.

You can optionally use the `committees` argument to provide a vector of committee ids to return just the departments of the given committees.

---

## Committee Memberships

Functions to download data on committee memberships.

---

_clcommittees_::__fetch_memberships__(_committee_id_, _summary = TRUE_, _fetch_name = TRUE_)  
_clcommittees_::__fetch_current_memberships__(_committee_id_, _summary = TRUE_, _fetch_name = TRUE_)  
_clcommittees_::__fetch_former_memberships__(_committee_id_, _summary = TRUE_, _fetch_name = TRUE_)  

Fetch data on the current and former members of a given committee and return it as a tibble containing one row per committee membership. `fetch_memberships` returns data on both the current and former members of the committee, while `fetch_current_memberships` and `fetch_former_memberships` return the current and former members respectively. 

The `committee_id` argument should be the committee id of a committee.

The `summary` argument is a boolean indicating whether to return a summary of key data or the full tibble. Setting `summary` to `TRUE` removes list columns and empty columns from the result.

The `fetch_name` argument is a boolean indicating whether to perform an additional API call to fetch the committee name and include it in a column of the results. The API endpoint that handles memberships does not return the committee name so this can be helpful in exploratory analysis.

---

_clcommittees_::__fetch_memberships_for_member__(_member_id_, _summary = TRUE_)  
_clcommittees_::__fetch_current_memberships_for_member___(_member_id_, _summary = TRUE_)  
_clcommittees_::__fetch_former_memberships_for_member__(_member_id_, _summary = TRUE_)  

Fetch data on the current and former committee memberships of a given member and return it as a tibble containing one row per committee membership. `fetch_memberships_for_member` returns data on both the current and former memberships of the member, while `fetch_current_memberships_for_member` and `fetch_former_memberships_for_member` return the current and former memberships respectively. 

The `member_id` argument should be the mnis id of a member.

The `summary`, argument is a boolean indicating whether to return a summary of key data or the full tibble. Setting `summary` to `TRUE` removes list columns and empty columns from the result.

---

## Committee Roles

Functions to download data on Members' roles on committees.

---

_clcommittees_::__fetch_member_roles__(_committee_id_)  
_clcommittees_::__fetch_current_member_roles__(_committee_id_)  
_clcommittees_::__fetch_former_member_roles__(_committee_id_)  

Fetch data on the roles of the current and former members of a given committee and return it as a tibble containing one row per committee role. `fetch_roles` returns data on the roles of both the current and former members, while `fetch_current_member_roles` and `fetch_former_member_roles` return the roles of current and former members respectively. 

A role indicates a period of service in a given position, so __these functions return __all__ the roles for this committee (both current and historic) for its current and/or former members__. A role without an end date is an active role and you can use that to identify e.g. current roles for current members.

A member may have concurrent roles for the same period reflecting different positions e.g. one indicating their service as a member and another their service as a chair.

The `committee_id` argument should be the committee id of a committee.

---

_clcommittees_::__fetch_roles_for_member__(_member_id_)  
_clcommittees_::__fetch_current_roles_for_member_id__(_member_)  
_clcommittees_::__fetch_former_roles_for_member_id__(_member_)  

Fetch data on the current and former committee roles of a given member and return it as a tibble containing one row per committee role. `fetch_roles_for_member` returns data on the member's current and former roles, while `fetch_current_roles_for_member` and `fetch_former_roles_for_member` return the member's current and former roles respectively.

A role indicates a period of service in a given position. A role without an end date is a current role.

A member may have concurrent roles for the same period reflecting different positions e.g. one indicating their service as a member and another their service as a chair.

The `member_id` argument should be the mnis id of a member.

---

## Requests

Functions to query the Committees API directly with a URL and get the results as a native R data structure. 

---

_clcommittees_::__request__(_url_)

Fetch the full json response to an API request as a nested list. 

The `url` argument should be a valid API URL.

---

_clcommittees_::__get_response_items__(_response_)  

Get the data items from an API response as a tibble.

In many (but not all) API calls the results data is stored in the "items" property of the json response. This function extracts the data items from an API response as a tibble and cleans the column names, converting them to snake case.

The `response` argument should be a response object returned from `request`.

---

_clcommittees_::__request_items__(_url_)  

Fetch just the data items contained in the response to an API request as a tibble. 

In many (but not all) API calls the results data is stored in the "items" property of the json response. This function first calls `request` and then calls `get_response_items` on `response$items`, returning the data as a tibble with clean column names.

The `url` argument should be a valid API URL.

---
