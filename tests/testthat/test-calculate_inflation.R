test_that("Inflation on the same date is 0", {
  expect_equal(
    calculate_inflation(
      date_from = as.Date("2020-01-01"),
      date_to = as.Date("2020-01-01")
    ),
    0
  )
})

# Source: https://www.financialafrik.com/2022/01/15/tunisie-linflation-repasse-legerement-a-la-hausse-en-2021/#:~:text=En%20Tunisie%2C%20la%20trajectoire%20d%C3%A9sinflationniste,%25%20durant%20l'ann%C3%A9e%202020.
test_that(
  "Annual inflation change on January 2021 is 4.9%",
  {
    expect_equal(
      round(calculate_inflation(
        date_from = as.Date("2020-01-01"),
        date_to = as.Date("2021-01-01")
      ), 3), 0.049
    )
  }
)


# Source: https://www.financialafrik.com/2022/01/15/tunisie-linflation-repasse-legerement-a-la-hausse-en-2021/#:~:text=En%20Tunisie%2C%20la%20trajectoire%20d%C3%A9sinflationniste,%25%20durant%20l'ann%C3%A9e%202020.
test_that(
  "Annual inflation change on December 2021 is 6.6%",
  {
    expect_equal(
      round(calculate_inflation(
        date_from = as.Date("2020-12-01"),
        date_to = as.Date("2021-12-01")
      ), 3), 0.066
    )
  }
)


# Source: https://www.financialafrik.com/2022/01/15/tunisie-linflation-repasse-legerement-a-la-hausse-en-2021/#:~:text=En%20Tunisie%2C%20la%20trajectoire%20d%C3%A9sinflationniste,%25%20durant%20l'ann%C3%A9e%202020.
test_that(
  "Annual inflation change on November 2021 is 6.4%",
  {
    expect_equal(
      round(calculate_inflation(
        date_from = as.Date("2020-11-01"),
        date_to = as.Date("2021-11-01")
      ), 3), 0.064
    )
  }
)

# Source: http://www.ins.tn/publication/indice-des-prix-la-consommation-septembre-2021

test_that("Annual inflation change on September 2021 is 6.2%", {
  expect_equal(
    round(calculate_inflation(
      date_from = as.Date("2020-09-01"),
      date_to = as.Date("2021-09-01")
    ), 3), 0.062
  )
})


# Source: https://www.financialafrik.com/2022/01/15/tunisie-linflation-repasse-legerement-a-la-hausse-en-2021/#:~:text=En%20Tunisie%2C%20la%20trajectoire%20d%C3%A9sinflationniste,%25%20durant%20l'ann%C3%A9e%202020.
# Test that average inflation in 2021 is 5.7%
# Test that average inflation in 2020 is 5.6%
