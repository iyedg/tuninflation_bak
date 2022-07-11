library(dplyr)
library(magrittr)

#' Calculate Inflation
#'
#' @param date_from Initial date
#' @param date_to Target date
#' @param base_year The base year used to calculate the underlying Consumer Price Index
#'
#' @return Inflation rate between the two provided dates.
#' @export
#'
#' @examples
#'
#' calculate_inflation(
#'   date_from = as.Date("2020-01-01"),
#'   date_to = as.Date("2022-01-01"),
#'   base_year = 2015
#' )
calculate_inflation <- function(date_from,
                                date_to,
                                base_year = 2015) {
  base_year_df <- consumer_price_index %>%
    dplyr::rename(
      base_year_ = base_year
    ) %>%
    dplyr::filter(base_year_ == base_year)

  cpi_from <- base_year_df %>%
    dplyr::filter(measurement_date == date_from) %>%
    dplyr::pull(cpi)


  cpi_to <- base_year_df %>%
    dplyr::filter(measurement_date == date_to) %>%
    dplyr::pull(cpi)

  (cpi_to - cpi_from) / cpi_from
}

#' Adjust for inflation
#'
#' @param value The *nominal* value to be adjusted for inflation (in TND)
#' @param date_from The date of measurement # Improve
#' @param date_to The Target Date
#' @param base_year The base year used to calculate the underlying Consumer Price Index
#'
#' @return The *real* value adjusted for inflation
#' @export
#'
#' @examples
#'
#' adjust_for_inflation(
#'   value = 100,
#'   date_from = as.Date("2020-01-01"),
#'   date_to = as.Date("2022-01-01"),
#'   base_year = 2015
#' )
adjust_for_inflation <- function(value,
                                 date_from,
                                 date_to,
                                 base_year) {
  inflation_rate <- calculate_inflation(date_from, date_to, base_year)
  value * inflation_rate
}
