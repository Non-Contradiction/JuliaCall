context("OptimalFeatureSelection")


test_that("classification", {
  skip_on_cran()

  if (iai:::iai_version_less_than("1.1.0")) {
    expect_error(iai::optimal_feature_selection_classifier(),
                 "requires IAI version 1.1.0")
    expect_error(iai::get_prediction_constant(),
                 "requires IAI version 1.1.0")
    expect_error(iai::get_prediction_weights(),
                 "requires IAI version 1.1.0")
  } else {
    X <- iris[, 1:4]
    y <- iris[, 5] == "setosa"
    lnr <- iai::optimal_feature_selection_classifier(
        random_seed = 1,
        sparsity = 3,
    )
    iai::fit(lnr, X, y)

    expect_true(is.numeric(iai::score(lnr, X, y)))
    expect_true(is.vector(iai::predict(lnr, X)))
    expect_true(is.data.frame(iai::predict_proba(lnr, X)))

    expect_true(is.numeric(iai::get_prediction_constant(lnr)))

    weights <- iai::get_prediction_weights(lnr)
    expect_true(is.list(weights))
    expect_true(is.list(weights$numeric))
    expect_true(is.list(weights$categoric))
    expect_equal(length(weights$categoric), 0)
  }
})


test_that("regression", {
  skip_on_cran()

  if (iai:::iai_version_less_than("1.1.0")) {
    expect_error(iai::optimal_feature_selection_regressor(),
                 "requires IAI version 1.1.0")
    expect_error(iai::get_prediction_constant(),
                 "requires IAI version 1.1.0")
    expect_error(iai::get_prediction_weights(),
                 "requires IAI version 1.1.0")
  } else {
    X <- mtcars[, 2:11]
    y <- mtcars[, 1]
    lnr <- iai::optimal_feature_selection_regressor(
        random_seed = 1,
        sparsity = 3,
    )
    iai::fit(lnr, X, y)

    expect_true(is.numeric(iai::score(lnr, X, y)))
    expect_true(is.vector(iai::predict(lnr, X)))

    expect_true(is.numeric(iai::get_prediction_constant(lnr)))

    weights <- iai::get_prediction_weights(lnr)
    expect_true(is.list(weights))
    expect_true(is.list(weights$numeric))
    expect_true(is.list(weights$categoric))
    expect_equal(length(weights$categoric), 0)
  }
})
