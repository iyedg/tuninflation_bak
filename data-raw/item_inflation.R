pacman::p_load(
  here,
  dplyr,
  magrittr,
  tidyr,
  ggplot2,
  readxl,
  readr,
  janitor,
  conflicted,
  stringr,
  fuzzyjoin,
  assertthat
)

conflict_prefer("lag", "dplyr")
conflict_prefer("filter", "dplyr")


item_inflation <- read_excel(
  path = here::here("data-raw/ipc_july_2022.xlsx"),
  sheet = "COICOP",
  skip = 6
) %>%
  clean_names() %>%
  select(-contains("moyenne")) %>%
  rename(
    ins_category = x1,
    weight = pond
  ) %>%
  pivot_longer(
    cols = -c(ins_category, weight),
    names_to = "measurement_period",
    values_to = "cpi"
  ) %>%
  mutate(
    measurement_period = as.numeric(str_remove(measurement_period, "x")),
    measurement_period = excel_numeric_to_date(measurement_period),
    cpi = as.numeric(cpi)
  ) %>%
  mutate(
    monthly_item_inflation = (cpi - lag(cpi, 1)) / lag(cpi, 1),
    yearly_item_inflation = (cpi - lag(cpi, 12)) / lag(cpi, 12)
  ) %>%
  rename(
    ins_weight_2015 = weight
  )

usethis::use_data(
  item_inflation,
  overwrite = TRUE,
  internal = TRUE,
  compress = "xz"
)
