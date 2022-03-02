#' print request to the console
#' @examples
#' ask_and_wait(text = "press enter to continue")
ask_and_wait <- function(text) {
  invisible(readline(prompt = text))
}


#' find from or select statements
#' @examples
#' find_statement(statement = "the 'from' statements you want to use")
find_statement <- function(statement) {
  need_statement <-
    paste(
      "Please highlight", statement, "and press [enter] to continue"
    )

  ask_and_wait(need_statement)

  rstudioapi::getSourceEditorContext()
}
