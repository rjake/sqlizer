#' Title
#'
#' @param table string of table name to find and append to keywords
#'
#' @examples
#' keyword_patterns(table = "mtcars")
keyword_patterns <- function(table) {
  keywords |>
    c(# original table name
      glue::glue("\\b{table}\\b"),
      # numbers
      "[0-9]"
    )  |>
    glue::glue_collapse("|")
}
