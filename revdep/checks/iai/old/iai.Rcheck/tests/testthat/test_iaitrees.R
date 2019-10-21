context("IAITrees")


test_that("common structure", {
  skip_on_cran()

  X <- JuliaCall::julia_eval(
      "IAIConvert.convert_to_R(IAI.IAIBase.generate_mixed_data())"
  )
  names(X) <- c("num_attempts", "score1", "score2", "score3", "num_children",
                "region")

  y <- X$score1 >= 50 &
         X$region %in% c("A", "B") |
       X$score1 < 50 &
         (X$score2 + 85 * X$score3 + 90 * (X$region == "E")) > 140

  lnr <- iai::optimal_tree_classifier(
      random_seed = 1,
      max_depth = 2,
      cp = 0.04,
      hyperplane_config = list(sparsity = "all"),
  )
  iai::fit(lnr, X, y)

  expect_equal(iai::get_num_nodes(lnr), 7)
  expect_equal(iai::is_leaf(lnr, 1), FALSE)
  expect_equal(iai::get_depth(lnr, 6), 2)
  expect_equal(iai::get_num_samples(lnr, 6), 97)
  expect_equal(iai::get_parent(lnr, 2), 1)
  expect_equal(iai::get_lower_child(lnr, 1), 2)
  expect_equal(iai::get_upper_child(lnr, 1), 5)
  expect_equal(iai::is_parallel_split(lnr, 1), TRUE)
  expect_equal(iai::is_hyperplane_split(lnr, 2), TRUE)
  expect_equal(iai::is_categoric_split(lnr, 5), TRUE)
  expect_equal(iai::is_ordinal_split(lnr, 1), FALSE)
  expect_equal(iai::is_mixed_parallel_split(lnr, 2), FALSE)
  expect_equal(iai::is_mixed_ordinal_split(lnr, 5), FALSE)
  expect_equal(iai::missing_goes_lower(lnr, 1), FALSE)
  expect_equal(iai::get_split_feature(lnr, 1), as.symbol("score1"))
  expect_equal(iai::get_split_threshold(lnr, 1), 49.79228179001239)
  expect_mapequal(iai::get_split_categories(lnr, 5), list(
      A = TRUE,
      B = TRUE,
      C = FALSE,
      D = FALSE,
      E = FALSE
  ))
  weights <- iai::get_split_weights(lnr, 2)
  expect_mapequal(weights$numeric, list(score2 = 0.010100076620278502,
                                        score3 = 2.0478494324868732))
  expect_mapequal(weights$categoric,
                  list(region = list(E = 1.5176596636410404)))
})


test_that("classification structure", {
  skip_on_cran()

  lnr <- JuliaCall::julia_eval(
      "IAI.OptimalTrees.load_iris_tree(random_seed=1)"
  )

  expect_equal(iai::get_classification_label(lnr, 2), "setosa")
  expect_mapequal(iai::get_classification_proba(lnr, 4), list(
      virginica = 0.09259259259259259,
      setosa = 0.0,
      versicolor = 0.9074074074074074
  ))
})


test_that("regression structure", {
  skip_on_cran()

  lnr <- JuliaCall::julia_eval(
      "IAI.OptimalTrees.load_mtcars_tree(random_seed=1,
                                         regression_sparsity=\"all\",
                                         regression_lambda=0.2)"
  )

  expect_equal(iai::get_regression_constant(lnr, 2), 30.879999999999995)
  expect_equal(iai::get_regression_constant(lnr, 3), 26.56192034262967)

  weights <- iai::get_regression_weights(lnr, 3)
  expect_mapequal(weights$numeric, list(Disp = -0.021044493648366,
                                        HP = -0.018861409939436))
  expect_true(is.list(weights$categoric) && length(weights$categoric) == 0)
})


test_that("survival structure", {
  skip_on_cran()

  iai::set_julia_seed(4)
  lnr <- JuliaCall::julia_eval("IAI.OptimalTrees.load_survival_tree()")

  curve <- iai::get_survival_curve(lnr, 2)
  curve_data <- iai::get_survival_curve_data(curve)
  expect_equal(curve_data$coefs, c(
            0.00000000, 0.02380952, 0.02597403, 0.02813853, 0.03030303,
            0.03246753, 0.03463203, 0.03679654, 0.03896104, 0.04112554,
            0.04329004, 0.04545455, 0.06734007, 0.08922559, 0.11111111,
            0.13299663, 0.15488215, 0.17676768, 0.19865320, 0.22053872,
            0.24242424))
  expect_equal(curve_data$times, c(
            00000, 11000, 12000, 13000, 14000, 15000, 16000, 17000, 18000,
            19000, 20000, 21000, 22000, 23000, 24000, 25000, 26000, 27000,
            28000, 29000, 30000))
})


test_that("prescription structure", {
  skip_on_cran()

  iai::set_julia_seed(2)
  lnr <- JuliaCall::julia_eval(
      "IAI.OptimalTrees.load_prescription_tree(regression_sparsity=\"all\",
                                               regression_lambda=0.22,
                                               max_depth=2)"
  )

  expect_equal(iai::get_prescription_treatment_rank(lnr, 2), c(1, 0))
  expect_equal(iai::get_regression_constant(lnr, 2, 0), 30.5)

  weights <- iai::get_regression_weights(lnr, 5, 1)
  expect_mapequal(weights$numeric, list(Disp = -0.007198454096246))
  expect_true(is.list(weights$categoric) && length(weights$categoric) == 0)
})


test_that("visualization", {
  skip_on_cran()

  lnr <- JuliaCall::julia_eval("IAI.OptimalTrees.load_iris_tree()")

  if (JuliaCall::julia_eval("IAI.IAITrees.has_graphviz()")) {
    iai::write_png("test.png", lnr)
    expect_true(file.exists("test.png"))
    file.remove("test.png")
  }

  iai::write_dot("test.dot", lnr)
  expect_true(file.exists("test.dot"))
  file.remove("test.dot")

  iai::write_html("tree.html", lnr)
  expect_true(file.exists("tree.html"))
  file.remove("tree.html")

  iai::write_questionnaire("question.html", lnr)
  expect_true(file.exists("question.html"))
  file.remove("question.html")

  if (iai:::iai_version_less_than("1.1.0")) {
    expect_error(iai::tree_plot(),
                 "requires IAI version 1.1.0")
    expect_error(iai::questionnaire(),
                 "requires IAI version 1.1.0")
    expect_error(iai::multi_tree_plot(),
                 "requires IAI version 1.1.0")
    expect_error(iai::multi_questionnaire(),
                 "requires IAI version 1.1.0")
  } else {
    feature_renames <- list(
      "PetalLength" = "A",
      "PetalWidth" = "B",
      "SepalWidth" = "C"
    )

    vis <- iai::tree_plot(lnr, feature_renames = feature_renames)
    expect_true("visualization" %in% class(vis))
    iai::write_html("tree_rename.html", vis)
    expect_true(file.exists("tree_rename.html"))
    file.remove("tree_rename.html")

    vis <- iai::questionnaire(lnr, feature_renames = feature_renames)
    expect_true("visualization" %in% class(vis))
    iai::write_html("questionnaire_rename.html", vis)
    expect_true(file.exists("questionnaire_rename.html"))
    file.remove("questionnaire_rename.html")

    questions <- list("Use learner with" = list(
      "renamed features" = lnr,
      "extra text output" = lnr
    ))

    vis <- iai::multi_tree_plot(questions)
    expect_true("visualization" %in% class(vis))
    iai::write_html("multitree.html", vis)
    expect_true(file.exists("multitree.html"))
    file.remove("multitree.html")

    vis <- iai::multi_questionnaire(questions)
    expect_true("visualization" %in% class(vis))
    iai::write_html("multiquestion.html", vis)
    expect_true(file.exists("multiquestion.html"))
    file.remove("multiquestion.html")
  }
})


test_that("tree API", {
  skip_on_cran()

  X <- iris[, 1:4]
  y <- iris$Species
  lnr <- iai::optimal_tree_classifier(max_depth = 1, cp = 0)
  iai::fit(lnr, X, y)

  expect_equal(length(iai::apply(lnr, X)), length(y))
  expect_equal(length(iai::apply_nodes(lnr, X)), iai::get_num_nodes(lnr))

  path <- iai::decision_path(lnr, X)
  expect_equal(nrow(path), length(y))
  expect_equal(ncol(path), iai::get_num_nodes(lnr))

  iai::print_path(lnr, X, 1)

  expect_true(is.data.frame(iai::variable_importance(lnr)))
})


test_that("classification tree API", {
  skip_on_cran()

  X <- iris[, 1:4]
  y <- iris$Species == "setosa"
  lnr <- iai::optimal_tree_classifier(max_depth = 1, cp = 0)
  iai::fit(lnr, X, y)

  expect_true(is.data.frame(iai::predict_proba(lnr, X)))

  expect_equal(iai::get_num_nodes(lnr), 3)
  iai::set_threshold(lnr, TRUE, 0, simplify = TRUE)
  expect_equal(iai::get_num_nodes(lnr), 1)

  iai::set_display_label(lnr, TRUE)
  expect_true(grepl("true)", print(lnr)))
  iai::reset_display_label(lnr)
  expect_false(grepl("true)", print(lnr)))
})


test_that("prescription tree API", {
  skip_on_cran()

  lnr <- iai::optimal_tree_prescription_maximizer(max_depth = 1, cp = 0)
  X <- matrix(rnorm(200), 100, 2)
  treatments <- rbinom(100, 1, 0.5)
  outcomes <- runif(100)
  iai::fit(lnr, X, treatments, outcomes)

  expect_true(is.data.frame(iai::predict_outcomes(lnr, X)))

  pred <- iai::predict(lnr, X)
  expect_true(is.list(pred))
  expect_equal(names(pred), c("treatments", "outcomes"))
})
