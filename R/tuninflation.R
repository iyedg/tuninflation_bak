
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
    }

    if (by_item == FALSE) {
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
                dplyr::summarise(cpi = mean(cpi))
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
    }
    if ("measurement_period" %in% names(inflation_df)) {
        inflation_df %>%
            dplyr::filter(measurement_period >= start_date)
    } else {
        inflation_df %>%
            dplyr::filter(measurement_year >= lubridate::year(start_date))
    }
}
