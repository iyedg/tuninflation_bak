# library(dplyr)
# library(magrittr)

# #' Calculate Inflation
# #'
# #' @param date_from Initial date
# #' @param date_to Target date
# #' @param base_year The base year used to calculate the underlying Consumer Price Index
# #'
# #' @return Inflation rate between the two provided dates.
# #' @export
# #'
# #' @examples
# #'
# #' calculate_inflation(
# #'   date_from = as.Date("2020-01-01"),
# #'   date_to = as.Date("2022-01-01"),
# #'   base_year = 2015
# #' )
# # calculate_inflation <- function(date_from,
# #                                 date_to,
# #                                 base_year = 2015) {
# #   base_year_df <- consumer_price_index %>%
# #     dplyr::rename(
# #       base_year_ = base_year
# #     ) %>%
# #     dplyr::filter(base_year_ == base_year)

# #   cpi_from <- base_year_df %>%
# #     dplyr::filter(measurement_period == date_from) %>%
# #     dplyr::pull(cpi)


# #   cpi_to <- base_year_df %>%
# #     dplyr::filter(measurement_period == date_to) %>%
# #     dplyr::pull(cpi)

# #   (cpi_to - cpi_from) / cpi_from
# # }

# # #' Adjust for inflation
# # #'
# # #' @param value The *nominal* value to be adjusted for inflation (in TND)
# # #' @param date_from The date of measurement # Improve
# # #' @param date_to The Target Date
# # #' @param base_year The base year used to calculate the underlying Consumer Price Index
# # #'
# # #' @return The *real* value adjusted for inflation
# # #' @export
# # #'
# # #' @examples
# # #'
# # #' adjust_for_inflation(
# # #'   value = 100,
# # #'   date_from = as.Date("2020-01-01"),
# # #'   date_to = as.Date("2022-01-01"),
# # #'   base_year = 2015
# # #' )
# # adjust_for_inflation <- function(value,
# #                                  date_from,
# #                                  date_to,
# #                                  base_year = 2015) {
# #   inflation_rate <- calculate_inflation(date_from, date_to, base_year)
# #   value * (1 + inflation_rate)
# # }




# #' Adjust for inflation (For dataframes)
# #'
# #' @param data dataframe
# #' @param values_col column name containing amounts to be adjusted for inflation
# #' @param date_from_col column name containing the observation dates
# #' @param date_to_col column name containing the target dates for adjustment
# #' @param base_year_col column name containing the base year # TODO: make it optional
# #' @param output_col column name for output values
# #'
# #' @return dataframe with added column for real values
# #' @export
# #'
# #' @examples
# #' \dontrun{
# #' data <- tibble::tibble(
# #'   budget = c(1, 1, 1, 1),
# #'   observation_date = c(
# #'     as.Date("2016-01-01"),
# #'     as.Date("2017-01-01"),
# #'     as.Date("2018-01-01"),
# #'     as.Date("2019-01-01")
# #'   ),
# #'   target_date = c(
# #'     as.Date("2015-01-01"),
# #'     as.Date("2015-01-01"),
# #'     as.Date("2015-01-01"),
# #'     as.Date("2015-01-01")
# #'   ),
# #'   base_year = c(2015, 2015, 2015, 2015)
# #' )
# #' data %>%
# #'   adjust_for_inflation2(
# #'     values_col = budget,
# #'     date_from_col = observation_date,
# #'     date_to_col = target_date,
# #'     base_year_col = base_year
# #'   )
# #' }
# # adjust_for_inflation2 <- function(data,
# #                                   values_col,
# #                                   date_from_col,
# #                                   date_to_col,
# #                                   base_year_col,
# #                                   output_col = "real_value") {
# #   params <- list(
# #     dplyr::pull(data, {{ values_col }}),
# #     dplyr::pull(data, {{ date_from_col }}),
# #     dplyr::pull(data, {{ date_to_col }}),
# #     dplyr::pull(data, {{ base_year_col }})
# #   )
# #   data %>%
# #     dplyr::mutate(
# #       real_value = unlist(purrr::pmap(params, adjust_for_inflation))
# #     )
# # }
