context("OptImpute")


X <- iris[, 1:4]
X[1, 1] <- NA


test_that("constructors", {
  skip_on_cran()

  lnr <- iai::opt_knn_imputation_learner()
  expect_true(is.data.frame(iai::fit_transform(lnr, X)))

  lnr <- iai::opt_svm_imputation_learner()
  expect_true(is.data.frame(iai::fit_transform(lnr, X)))

  lnr <- iai::opt_tree_imputation_learner()
  expect_true(is.data.frame(iai::fit_transform(lnr, X)))

  lnr <- iai::single_knn_imputation_learner()
  expect_true(is.data.frame(iai::fit_transform(lnr, X)))

  lnr <- iai::mean_imputation_learner()
  expect_true(is.data.frame(iai::fit_transform(lnr, X)))

  lnr <- iai::rand_imputation_learner()
  expect_true(is.data.frame(iai::fit_transform(lnr, X)))
})


test_that("impute grid", {
  skip_on_cran()

  grid <- iai::grid_search(iai::imputation_learner())
  iai::fit_cv(grid, X)
  expect_true(is.data.frame(iai::transform(grid, X)))
  expect_true(is.data.frame(iai::fit_transform_cv(grid, X)))
})
