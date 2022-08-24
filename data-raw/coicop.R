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
  fuzzyjoin
)

`%nin%` <- Negate(`%in%`)


conflict_prefer("lag", "dplyr")
conflict_prefer("filter", "dplyr")


top_level_categories <- c(
  "Produits alimentaires et boissons non alcoolisées",
  "Boissons alcoolisées et tabac",
  "Articles d'habillement et chaussures",
  "Logement, eau, gaz, électricité et autres combustibles",
  "Meubles, articles de ménage et entretien courant du foyer",
  "Santé",
  "Transports",
  "Communications",
  "Loisirs et culture",
  "Enseignement",
  "Restaurants et hôtels",
  "Biens et services divers"
)

# ! Loading Data

ins_categories <- read_excel(
  path = here::here("data-raw/ipc_july_2022.xlsx"),
  sheet = "COICOP",
  skip = 6
) %>%
  clean_names() %>%
  rename(
    category = x1,
    weight = pond
  ) %>%
  distinct(category, weight) %>%
  mutate(
    category = str_trim(category),
    level = case_when(
      category %in% top_level_categories ~ 1,
      TRUE ~ NA_real_
    )
  ) %>%
  filter(weight < max(weight))


coicop <- read_excel(
  here("data-raw/COICOP.xls"),
  skip = 2
) %>%
  clean_names() %>%
  select(code_diff, level, fr_desc) %>%
  filter(
    str_detect(code_diff, regex("^CP"))
  ) %>%
  mutate(
    division = str_extract(code_diff, regex("(?<=^CP)\\d{2}")),
    group = str_extract(code_diff, regex("(?<=^CP\\d{2})\\d{1}")),
    class = str_extract(code_diff, regex("(?<=^CP\\d{3})\\d{1}"))
  ) %>%
  rename(coicop_desc_fr = fr_desc)


# ! Matching categories

## ! Matching top level categories


ins_categories_l1 <- ins_categories %>%
  filter(level == 1) %>%
  select(-level) %>%
  stringdist_inner_join(coicop %>%
    filter(level == 1),
  by = c(category = "coicop_desc_fr"),
  method = "jw",
  max_dist = 0.3
  ) %>%
  right_join(ins_categories)

# ! Utilities

clean_join <- function(df) {
  df %>%
    mutate(
      code_diff = coalesce(code_diff.x, code_diff.y),
      level = coalesce(level.x, level.y),
      division = coalesce(division.x, division.y),
      group = coalesce(group.x, group.y),
      class = coalesce(class.x, class.y),
      coicop_desc_fr = coalesce(coicop_desc_fr.x, coicop_desc_fr.y),
    ) %>%
    select(-ends_with(".x")) %>%
    select(-ends_with(".y"))
}

level_join <- function(df, target_level) {
  coicop %>%
    filter(level == target_level) %>%
    stringdist_inner_join(df %>%
      filter(is.na(level)) %>%
      select(category),
    by = c(coicop_desc_fr = "category"),
    ) %>%
    right_join(df, by = "category") %>%
    clean_join()
}

## ! Matching the remaining levels

ins_strictly_matched <- ins_categories_l1 %>%
  level_join(target_level = 2) %>%
  level_join(target_level = 3)

ins_unmatched_df <- ins_strictly_matched %>%
  filter(is.na(level))

coicop_unmatched_df <- coicop %>%
  filter(
    level <= 3,
    coicop_desc_fr %nin% ins_strictly_matched$coicop_desc_fr
  )

ins_matched_lax <- ins_unmatched_df %>%
  select(category) %>%
  stringdist_left_join(coicop_unmatched_df,
    by = c(category = "coicop_desc_fr"),
    method = "jw",
    max_dist = 0.2,
    distance_col = "distance"
  ) %>%
  group_by(category) %>%
  filter(distance == min(distance), level == min(level)) %>%
  ungroup() %>%
  select(-distance) %>%
  right_join(ins_strictly_matched, by = "category") %>%
  clean_join()

wrong_matches <- c("Services ambulatoires", "Livres Scolaires")

ins_matched_lax <- ins_matched_lax %>%
  # This mutate basically resets match by setting all matching columns to NA
  mutate(
    across(
      c(code_diff, division, group, class, coicop_desc_fr),
      ~ if_else(category %in% wrong_matches, NA_character_, .x)
    ),
    level = if_else(category %in% wrong_matches, NA_real_, level)
  )

### ! Manual matching

ins_unmatched_lax <- ins_matched_lax %>%
  filter(is.na(level))

coicop_unmatched_lax <- coicop %>%
  filter(
    level <= 3,
    coicop_desc_fr %nin% ins_matched_lax$coicop_desc_fr
  )

manual_matches <- tibble(
  category = c(
    "Entretien et réparation des logements",
    "Autres biens durables à fonction récréative et culturelle",
    "Outillage et autre matériel pour la maison et le jardin",
    "Huiles alimentaires",
    "Chaussures",
    "Alimentation en eau et services divers liés au logement",
    "Dépenses d'utilisation des véhicules",
    "Journaux, livres et articles de papeterie",
    "Restaurants et Cafés",
    "Poissons",
    "Matériel de téléphonie",
    "Accessoires d'habillement",
    "Loyers effectifs",
    "Matériel audiovisuel, photographique et de traitement de l'information",
    "Services ambulatoires",
    "Livres Scolaires"
  ),
  code_diff = c(
    "CP043",
    "CP092",
    "CP055",
    "CP0115",
    "CP0321",
    "CP044",
    "CP072",
    "CP095",
    "CP1111",
    "CP0113",
    "CP082",
    "CP0313",
    "CP041",
    "CP091",
    "CP062",
    "CP09512"
  )
)

ins_coicop <- ins_matched_lax %>%
  left_join(manual_matches, by = "category") %>%
  mutate(
    code_diff = coalesce(code_diff.x, code_diff.y)
  ) %>%
  select(-contains(".")) %>%
  left_join(coicop, by = "code_diff", keep = TRUE) %>%
  clean_join()

ins_coicop <- ins_coicop %>%
  rename(
    ins_category = category,
    ins_weight_2015 = weight,
    id_coicop = code_diff,
    coicop_category_fr = coicop_desc_fr
  )

