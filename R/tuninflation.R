#' tuninflation
#'
#' @param base_year The base year for CPI values
#' @param start_date The date from which to start computing inflation
#' @param end_date The date at which to stop computing inflation
#' @param by_item Whether to compute inflation broken down by consumption components
#' @param frequency The frequency of reported results, can be either 'yearly' or 'monthly'
#' @param relative_to The reference point in time relative to which inflation is computed. Can be either 'year' or 'month'
#'
#' @return A dataframe with an index matching the provided frequency, and column for inflation computed relative to the provided frame of reference
#' @export
tuninflation <- function(base_year = 2015,
                         start_date,
                         end_date,
                         by_item = FALSE,
                         frequency = "yearly",
                         relative_to = "year") {
  assertthat::assert_that(frequency %in% c("yearly", "monthly"),
    msg = "frequency must be either 'yearly' or 'monthly'"
  )

  assertthat::assert_that(relative_to %in% c("year", "month"),
    msg = "relative_to must be either 'year' or 'month'"
  )

  assertthat::assert_that(
    (frequency == "yearly" & relative_to == "month") == FALSE,
    msg = "Yearly inflation is computed relative to a previous year only"
  )

  assertthat::assert_that(end_date > start_date)

  assertthat::assert_that((by_item == TRUE & base_year != 2015) == FALSE,
    msg = "Disaggregated data is only available for the base year 2015"
  )
  if (by_item == FALSE) {
    base_years <- consumer_price_index %>%
      dplyr::distinct(base_year) %>%
      dplyr::pull(base_year)
    assertthat::assert_that(
      base_year %in% base_years,
      msg = "invalid base year"
    )

    cpi_df <- consumer_price_index
    if (frequency == "yearly") {
      # ! assume that relative_to is 'year', and that the user has been warned otherwise
      subset_df <- cpi_df %>%
        dplyr::filter(
          {{ base_year }} == base_year,
          lubridate::year(measurement_period) >= (lubridate::year(start_date) - 1),
          lubridate::year(measurement_period) <= lubridate::year(end_date)
        )
      inflation_df <- subset_df %>%
        dplyr::mutate(measurement_year = lubridate::year(measurement_period)) %>%
        dplyr::group_by(measurement_year) %>%
        dplyr::summarise(cpi = mean(cpi)) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(
          inflation = (cpi - dplyr::lag(cpi, 1)) / dplyr::lag(cpi, 1)
        )
    } else {
      subset_df <- cpi_df %>%
        dplyr::filter(
          {{ base_year }} == base_year,
          measurement_period >= lubridate::add_with_rollback(start_date, -lubridate::years(1)), # ! TODO: substract 1 month
          measurement_period <= end_date
        )
      if (relative_to == "year") {
        inflation_df <- subset_df %>%
          dplyr::mutate(
            inflation = (cpi - dplyr::lag(cpi, 12)) / dplyr::lag(cpi, 12)
          )
      } else {
        inflation_df <- subset_df %>%
          dplyr::mutate(
            inflation = (cpi - dplyr::lag(cpi, 1)) / dplyr::lag(cpi, 1)
          )
      }
    }
  } else {
    cpi_df <- consumer_price_index_by_item

    if (frequency == "yearly") {
      subset_df <- cpi_df %>%
        dplyr::filter(
          {{ base_year }} == base_year,
          lubridate::year(measurement_period) >= (lubridate::year(start_date) - 1),
          lubridate::year(measurement_period) <= lubridate::year(end_date)
        )
      inflation_df <- subset_df %>%
        dplyr::mutate(measurement_year = lubridate::year(measurement_period)) %>%
        dplyr::group_by(measurement_year, ins_category, ins_weight_2015) %>%
        dplyr::summarise(cpi = mean(cpi)) %>%
        dplyr::ungroup() %>%
        dplyr::arrange(ins_weight_2015, measurement_year) %>%
        dplyr::mutate(
          inflation = (cpi - dplyr::lag(cpi, 1)) / dplyr::lag(cpi, 1)
        )
    } else {
      if (relative_to == "year") {
        inflation_df <- cpi_df %>%
          dplyr::group_by(ins_category) %>%
          dplyr::arrange(ins_category, measurement_period) %>%
          dplyr::mutate(
            inflation = (cpi - dplyr::lag(cpi, 12)) / dplyr::lag(cpi, 12)
          ) %>%
          dplyr::ungroup()
      } else {
        inflation_df <- cpi_df %>%
          dplyr::group_by(ins_category) %>%
          dplyr::arrange(ins_category, measurement_period) %>%
          dplyr::mutate(
            inflation = (cpi - dplyr::lag(cpi, 1)) / dplyr::lag(cpi, 1)
          )
      }
    }
  }

  if ("measurement_period" %in% names(inflation_df)) {
    inflation_df %>%
      dplyr::filter(measurement_period >= start_date)
  } else {
    inflation_df %>%
      dplyr::filter(measurement_year >= lubridate::year(start_date))
  }
}
