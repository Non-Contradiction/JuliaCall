context("IAIBase")


X <- iris[, 1:4]
y <- iris$Species

test_that("Split data and fitting",  {
  skip_on_cran()

  # Test numeric indexing of list returns
  split <- iai::split_data("classification", X, y, train_proportion = 0.75)
  train_X <- split[[1]][[1]]
  train_y <- split[[1]][[2]]
  test_X <- split[[2]][[1]]
  test_y <- split[[2]][[2]]

  expect_equal(nrow(train_X) + nrow(test_X), nrow(X))
  expect_equal(length(train_y) + length(test_y), length(y))

  # Test prescription names
  treatments <- y
  outcomes <- X[, 1]
  split <- iai::split_data("prescription_minimize", X, treatments, outcomes)
  train_X <- split$train$X
  train_treatments <- split$train$treatments
  train_outcomes <- split$train$outcomes
  test_X <- split$test$X
  test_treatments <- split$test$treatments
  test_outcomes <- split$test$outcomes

  expect_equal(nrow(train_X) + nrow(test_X), nrow(X))
  expect_equal(length(train_treatments) + length(test_treatments),
               length(treatments))
  expect_equal(length(train_outcomes) + length(test_outcomes), length(outcomes))
})


test_that("Split mixed data",  {
  skip_on_cran()

  # Add a mixed data column (numeric + categoric)
  tmp <- 10 * X[, 4]
  tmp[1:5] <- NA
  tmp[6:10] <- "not measured"
  X$numericmixed <- iai::as.mixeddata(tmp, c("not measured"))

  # Add another mixed data column (ordinal + categoric)
  tmp2 <- c(rep("Small", 40), rep("Medium", 60), rep("Large", 50))
  tmp2[1:5] <- "not measured"
  tmp2[6:10] <- NA
  X$ordinalmixed <- iai::as.mixeddata(tmp2, c("not measured"),
                                      c("Small", "Medium", "Large"))

  # Split into derivation and testing
  split <- iai::split_data("classification", X, y, train_proportion = 0.75)
  train_X <- split[[1]][[1]]
  train_y <- split[[1]][[2]]
  test_X <- split[[2]][[1]]
  test_y <- split[[2]][[2]]

  # Check if the combined split_data outputs are the same as original
  expect_true(all(
      c(train_X$numericmixed, test_X$numericmixed) %in% X$numericmixed))
  expect_true(all(
      X$numericmixed %in% c(train_X$numericmixed, test_X$numericmixed)))

  expect_true(all(
      c(train_X$ordinalmixed, test_X$ordinalmixed) %in% X$ordinalmixed))
  expect_true(all(
      X$ordinalmixed %in% c(train_X$ordinalmixed, test_X$ordinalmixed)))

})


test_that("grid_search", {
  skip_on_cran()

  grid <- iai::grid_search(
      iai::optimal_tree_classifier(
          random_seed = 1,
          max_depth = 1,
      ),
  )
  iai::fit(grid, X, y)

  expect_equal(iai::get_best_params(grid), list(cp = 0.25))
  expect_true(is.data.frame(iai::get_grid_results(grid)))

  expect_true("optimal_tree_learner" %in% class(iai::get_learner(grid)))
})


test_that("roc_curve", {
  skip_on_cran()

  lnr <- iai::optimal_tree_classifier(max_depth = 0, cp = 0)
  iai::fit(lnr, X, y == "setosa")
  roc <- iai::roc_curve(lnr, X, y == "setosa")

  expect_true("roc_curve" %in% class(roc))
})


test_that("rich output", {
  skip_on_cran()

  iai::set_rich_output_param("test", "abc")
  expect_equal(iai::get_rich_output_params(), list(test = "abc"))
  iai::delete_rich_output_param("test")
  params <- iai::get_rich_output_params()
  expect_true(is.list(params) && length(params) == 0)
})


test_that("learner params", {
  skip_on_cran()

  lnr <- iai::optimal_tree_classifier(cp = 0)
  iai::set_params(lnr, max_depth = 1)
  expect_equal(iai::get_params(lnr)$max_depth, 1)

  iai::fit(lnr, X, y)

  new_lnr <- iai::clone(lnr)
  expect_true("optimal_tree_learner" %in% class(new_lnr))
  # Clone has same params
  expect_equal(iai::get_params(new_lnr)$max_depth, 1)
  # Clone is not fitted
  expect_error(iai::predict(new_lnr))
})
