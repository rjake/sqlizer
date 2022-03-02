#' Line by line function to swap out text
#' @examples
#' append_text(code = "select max(case when 123 between x and y then 1 else 0 end) as w from sys.db.visit", table = "visit")
append_text <- function(code, table) {
  # if starts with comment, skip
  if (stringr::str_detect(trimws(code), "^--")) {
    return(code)
  }

  kewords_collapsed <- keyword_patterns(table)
  all_patterns <- glue::glue("\\b(?!({kewords_collapsed}))\\b(\\w+)")

  # append table name to second word
  all_replacements <- glue::glue("{table}.\\2")

  # finds table.xyz and used to remove in certain instances (see below)
  table_search <- glue::glue("\\b{table}\\.")

  stringr::str_replace_all(
    code,
    pattern = all_patterns,
    replacement = all_replacements
  ) |>
    # apply fixes
    stringr::str_remove_all(glue::glue("(?<=as ){table_search}")) |>            # as statements
    stringr::str_remove_all(glue::glue("(?<='){table_search}")) |>              # words next to starting quotes
    stringr::str_replace_all(glue::glue("({table_search})(\\w+)(')"), "\\2\\3") # words next to ending quotes
}


#' function to append aliases in code
#' called without arguments
#' @export
#' @examples
#' demo_sql("rooms"); append_table_name()
#' open_sql("inst/rooms.sql")
append_table_name <- function() {
  from_statement <- find_statement(statement = "the table you want to use")
  from_text <- from_statement$selection[[1]]$text |> trimws()

  table_qualified <- #                       |-qualified?----|
    stringr::str_extract_all(from_text, "\\w+\\.(\\w+)?\\.\\w+")[[1]]

  if (length(table_qualified) == 0) {
    warning("Expecting fully qualified table ex: 'db.owner.table'")
  }
  if (length(table_qualified) > 1) {
    stop("Expecting a single table")
  }

  table_name <- stringr::str_extract(table_qualified, "\\w+$")

  # the code will inadvertently add the table name at each period in the qualified table
  # x.y.Z will become Z.x.Z.y.Z
  # this is used in a regex to revert this error
  wrong_table_update <- append_text(table_qualified, table_name)

  # clear selection
  rstudioapi::setSelectionRanges(
    from_statement$selection[[1]]$range[[1]],
    id = from_statement$id
  )

  whole_query <- find_statement(statement = "your whole query")
  whole_query_text <- whole_query$selection[[1]]$text

  each_line <- stringr::str_split(whole_query_text, "\\n")[[1]]

  update_code <- purrr::map_chr(each_line, append_text, table_name)

  new_text <-
    glue::glue_collapse(update_code, "\n") |>
    stringr::str_replace_all(wrong_table_update, table_qualified) # replace qualified database error

  if (stringr::str_detect(new_text, "'")) {
    warning(glue::glue("Check strings in quotes, '{table_name}.' might be added"))
  }

  rstudioapi::modifyRange(
    location = whole_query$selection[[1]]$range,
    text = new_text,
    id = whole_query$id
  )
}
