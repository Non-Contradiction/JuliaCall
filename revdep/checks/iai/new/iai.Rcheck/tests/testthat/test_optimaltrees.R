context("OptimalTrees")


test_that("classification json", {
  skip_on_cran()

  lnr <- JuliaCall::julia_eval("IAI.OptimalTrees.load_iris_tree()")

  iai::write_json("classification.json", lnr)
  new_lnr <- iai::read_json("classification.json")
  file.remove("classification.json")
  expect_true("optimal_tree_learner" %in% class(new_lnr))
})


test_that("regression json", {
  skip_on_cran()

  lnr <- JuliaCall::julia_eval("IAI.OptimalTrees.load_mtcars_tree()")

  iai::write_json("regression.json", lnr)
  new_lnr <- iai::read_json("regression.json")
  file.remove("regression.json")
  expect_true("optimal_tree_learner" %in% class(new_lnr))
})


test_that("survival json", {
  skip_on_cran()

  lnr <- JuliaCall::julia_eval("IAI.OptimalTrees.load_survival_tree()")

  iai::write_json("survival.json", lnr)
  new_lnr <- iai::read_json("survival.json")
  file.remove("survival.json")
  expect_true("optimal_tree_learner" %in% class(new_lnr))
})


test_that("prescription json", {
  skip_on_cran()

  for (sense in c("min", "max")) {
    jl_eval <- stringr::str_interp(
        "IAI.OptimalTrees.load_prescription_tree(:${sense})"
    )
    lnr <- JuliaCall::julia_eval(jl_eval)

    iai::write_json("prescription.json", lnr)
    new_lnr <- iai::read_json("prescription.json")
    file.remove("prescription.json")
    expect_true("optimal_tree_learner" %in% class(new_lnr))
  }
})
