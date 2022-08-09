#' Consumer Price Index.
#'
#' A dataset containing the consumer price index as measured by the
#' Tunisian Statistics' National Institute (INS) since 1962.
#'
#' @format A data frame with 53940 rows and 10 variables:
#' \describe{
#'   \item{base_year}{Base year used for measurements. This is important as a change in base year reflects a change in the consumer basket used.}
#'   \item{cpi}{The value of the Consumer Price Index}
#'   \item{measurement_date}{The date of measurement (Month)}
#' }
#' @source \url{"http://www.ins.tn/publication/indice-des-prix-la-consommation"}
"consumer_price_index"


#' National Institute of Statistics (INS) to COICOP correspondence table.
#'
#' A correspondence table between the categories used by the INS for the
#' consumer price index and the international standard COICOP.
#' The dataset includes also the weights used by the INS for the base year 2015.
#'
#' @format A data frame with 66 rows and 8 variables:
#' \describe{
#'   \item{ins_category}{The category name used by the INS}
#'   \item{ins_weight_2015}{The weight of the category in the base basket of goods for 2015}
#'   \item{id_coicop}{The COICOP ID}
#'   \item{level}{The level of the category in the hierarchy}
#'   \item{division}{The COICOP division}
#'   \item{group}{The COICOP group}
#'   \item{class}{The COICOP class}
#'   \item{coicop_category_fr}{The COICOP category name in French}
#' }
#' @source \url{"http://www.ins.tn/publication/indice-des-prix-la-consommation-juillet-2022"}
"ins_coicop"


#' Inflation (monthly and annual) by item since 2015, using 2015 as a base year.
#'
#' @format A data frame with 6097 rows and 6 variables:
#' \describe{
#'   \item{ins_category}{The category name used by the INS}
#'   \item{ins_weight_2015}{The weight of the category in the base basket of goods for 2015}
#'   \item{measurement_period}{The month of measurement}
#'   \item{cpi}{The value of the Consumer Price Index on the specified date}
#'   \item{monthly_item_inflation}{Inflation of the item between the specified month and the previous one}
#'   \item{yearly_item_inflation}{Inflation of the item between the specified month and the same month from a year before}
#' }
#' @source \url{"http://www.ins.tn/publication/indice-des-prix-la-consommation-juillet-2022"}
"item_inflation"
