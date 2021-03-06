context("AutoFSelect")

test_that("train and predict work", {
  task = TEST_MAKE_TSK()
  learner = lrn("regr.rpart")
  resampling = rsmp("holdout")
  measures = msr("dummy")
  fselector = fs("sequential")
  terminator = trm("evals", n_evals = 4L)

  at = AutoFSelect$new(learner, resampling, measures, terminator, fselector)
  expect_learner(at)
  at$train(task)
  expect_learner(at)
  inst = at$fselect_instance
  a = inst$archive$data()
  expect_data_table(a, nrows = 4L)
  r = at$fselect_result
  expect_equal(r$x1, TRUE)
  expect_equal(r$x2, FALSE)
  expect_equal(r$x3, FALSE)
  expect_equal(r$x4, FALSE)
  prd = at$predict(task)
  expect_prediction(prd)
  expect_is(at$learner$model, "rpart")
})

test_that("AutoFSelect - resample", {
  task = TEST_MAKE_TSK()
  learner = lrn("regr.rpart")
  resampling_inner = rsmp("holdout")
  measures = msr("dummy")
  fselector = fs("sequential")
  terminator = trm("evals", n_evals = 10L)

  at = AutoFSelect$new(learner, resampling_inner, measures, terminator,
    fselector = fselector)
  expect_null(at$fselect_instance)

  resampling_outer = rsmp("cv", folds = 2)
  rr = resample(task, at, resampling_outer, store_models = TRUE)
  tab = as.data.table(rr)

  expect_data_table(tab, nrows = 2)
  expect_data_table(tab$learner[[1]]$archive$data(), nrows = 10)
  expect_data_table(tab$learner[[2]]$archive$data(), nrows = 10)
  expect_equal(tab$learner[[1]]$fselect_result$x1, TRUE)
  expect_equal(tab$learner[[1]]$fselect_result$x2, TRUE)
  expect_equal(tab$learner[[1]]$fselect_result$x3, TRUE)
  expect_equal(tab$learner[[1]]$fselect_result$x4, FALSE)
  expect_equal(tab$learner[[2]]$fselect_result$x1, TRUE)
  expect_equal(tab$learner[[2]]$fselect_result$x2, TRUE)
  expect_equal(tab$learner[[2]]$fselect_result$x3, TRUE)
  expect_equal(tab$learner[[2]]$fselect_result$x4, FALSE)
  expect_numeric(tab$learner[[1]]$fselect_result$dummy, len = 1L)
  expect_numeric(tab$learner[[2]]$fselect_result$dummy, len = 1L)
  expect_class(tab$learner[[1]]$model$learner$model, "rpart")
  expect_class(tab$learner[[2]]$model$learner$model, "rpart")
  expect_null(at$archive)
})
