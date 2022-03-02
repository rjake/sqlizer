#' called without arguments
#' @importFrom stringr str_remove_all str_replace_all
#' @importFrom stats na.omit
#' @examples
#' demo_sql(); replace_tab_with_space()
replace_tab_with_space <- function() {
  from_statement <- find_statement(statement = "the statements you want to use")
  from_text <- from_statement$selection[[1]]$text
  #cat(from_text)

  new_text <-
    from_text |>
    str_replace_all("\t", "    ")

  rstudioapi::modifyRange(
    location = from_statement$selection[[1]]$range,
    text = new_text,
    id = from_statement$id
  )

  # clear selection
  rstudioapi::setSelectionRanges(
    from_statement$selection[[1]]$range[[1]],
    id = from_statement$id
  )
}
