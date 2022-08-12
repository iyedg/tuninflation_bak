## code to prepare `consumer_price_index` dataset goes here
library(rvest)
library(dplyr)
library(tidyr)
library(readxl)
library(lubridate)
library(conflicted)
library(stringr)
library(glue)

conflict_prefer("lag", "dplyr")
conflict_prefer("filter", "dplyr")

months <- c(
  "janvier",
  "fevrier",
  "mars",
  "avril",
  "mai",
  "juin",
  "juillet",
  "aout",
  "septembre",
  "octobre",
  "novembre ",
  "decembre"
)

reference_date <- today() %m-% months(1)

year <- year(reference_date)
month <- months[month(reference_date)]

url_template <- "http://www.ins.tn/publication/indice-des-prix-la-consommation-{month}-{year}"

html_content <- rvest::read_html(glue(url_template))

data_url <- html_content %>%
  html_element(".file.file--mime-application-vnd-openxmlformats-officedocument-spreadsheetml-sheet.file--x-office-spreadsheet.icon-before") %>%
  html_element("a") %>%
  html_attr("href")
httr::GET(data_url, httr::write_disk(tf <- tempfile(fileext = ".xlsx")))


raw_consumer_price_index <- read_excel(tf, sheet = 2, skip = 11)


DATE_ORIGIN <- "1899-12-30"

month_to_n_fr <- c(
  "Janvier" = "1",
  "Février" = "2",
  "Mars" = "3",
  "Avril" = "4",
  "Mai" = "5",
  "Juin" = "6",
  "Juillet" = "7",
  "Août" = "8",
  "Septembre" = "9",
  "Octobre" = "10",
  "Novembre" = "11",
  "Décembre" = "12"
)


consumer_price_index <- raw_consumer_price_index %>%
  janitor::clean_names() %>%
  filter(annee != "Mois", annee != "Moyenne annuelle") %>%
  select(-mensuelle) %>% # Unused column
  rename(measurement_date = annee) %>%
  mutate(
    measurement_year = case_when(
      str_detect(measurement_date, regex("^\\d{4}$")) ~ measurement_date,
      TRUE ~ NA_character_
    ), # The year is available only in some rows, moved to another column to be later filled downward
    measurement_date = case_when(
      str_detect(
        measurement_date,
        regex("^\\d{5}$")
      ) ~ as.character(
        month(as.Date(as.numeric(measurement_date), DATE_ORIGIN))
      ),
      TRUE ~ as.character(measurement_date)
    ) # Harmonize values starting from 2014 which are read as Excel dates,
  ) %>%
  tidyr::fill(measurement_year, .direction = "down") %>%
  filter(str_detect(measurement_date, regex("^\\d{4}$"), negate = T)) %>%
  mutate(
    measurement_date = str_replace_all(measurement_date, month_to_n_fr),
    measurement_date = str_c(measurement_date, measurement_year, sep = "-"),
    measurement_date = lubridate::my(measurement_date)
  ) %>%
  select(-measurement_year) %>%
  pivot_longer(
    cols = -c(measurement_date),
    names_to = "base_year",
    values_to = "cpi",
    names_transform = list(base_year = as.character),
    values_transform = list(cpi = as.character)
  ) %>%
  mutate(
    cpi = as.numeric(cpi),
    base_year = as.numeric(str_remove(base_year, "x"))
  ) %>%
  arrange(base_year, measurement_date) %>%
  rename(
    measurement_period = measurement_date
  )


usethis::use_data(consumer_price_index,
  overwrite = TRUE,
  internal = TRUE,
  compress = "xz"
)
