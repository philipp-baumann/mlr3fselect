#' @title Feature Selection via Exhaustive Search
#'
#' @description
#' `FSelectorExhaustiveSearch` class that implements an Exhaustive Search.
#'
#' In order to support general termination criteria and parallelization, feature
#' sets are evaluated in batches. The size of the feature sets is increased by 1
#' in each batch.
#'
#' @templateVar id exhaustive_search
#' @template section_dictionary_fselectors
#'
#' @section Parameters:
#' \describe{
#' \item{`max_features`}{`integer(1)`\cr
#' Maximum number of features. By default, number of features in [mlr3::Task].}
#' }
#'
#' @export
#' @template example
FSelectorExhaustiveSearch = R6Class("FSelectorExhaustiveSearch",
  inherit = FSelector,
  public = list(

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function() {
      ps = ParamSet$new(list(
        ParamInt$new("max_features", lower = 1))
      )

      super$initialize(param_set = ps, properties = "single-crit")
    }
  ),
  private = list(
    .optimize = function(inst) {
      pars = self$param_set$values
      feature_names = inst$archive$cols_x
      archive = inst$archive

      if (is.null(pars$max_features)) {
        pars$max_features = length(feature_names)
      }

      repeat({
        if (archive$n_batch + 1 > pars$max_features) {
          stop(terminated_error(inst))
        }

        combinations = combn(length(feature_names),
          archive$n_batch + 1)
        states = map_dtr(seq_len(ncol(combinations)), function(j) {
          state = rep(0, length(feature_names))
          state[combinations[, j]] = 1
          state = as.list(as.logical(state))
          names(state) = feature_names
          state
        })
        inst$eval_batch(states)
      })
    }
  )
)

mlr_fselectors$add("exhaustive_search", FSelectorExhaustiveSearch)