#' build list of alias patterns
#' @importFrom tibble tibble
#' @importFrom stringr str_split str_detect str_remove_all str_replace_all str_c str_extract
#' @importFrom dplyr filter mutate
#' @importFrom purrr set_names
#' @examples
#' x <- find_statement(statement = "highlight a from statement")$selection[[1]]$text
#' find_alias_replacements(x)
find_alias_replacements <- function(x) {
  df <-
    tibble(orig_text = str_split(tolower(x), "\\n")[[1]]) %>%
    filter(nchar(orig_text) > 0) %>%
    filter(!str_detect(trimws(orig_text), "--")) %>%
    mutate(
      search =
        str_remove_all(orig_text, "^([\\w ]+)?\\bjoin\\b ") %>%
        str_remove_all(" on .*|as ") %>%
        str_replace_all(" {2,}", " ") %>%
        trimws(),
      alias = str_extract(search, "\\w+$"),
      alias_alone = str_c("((as)? \\b", alias, "(\\n| |$))" ),
      alias_appended = str_c("\\b", alias, "\\b"),
      table = str_extract(search, "(\\w+)(?=[ ]+\\w+$)"),
      first_join = !str_detect(orig_text, "\\bjoin\\b")
    )

  first_statement <- filter(df, first_join)
  other_statements <- filter(df, !first_join)

  output <-
    list(
      orig_text = df$orig_text,
      replace_appended =
        set_names(
          x = df$table,
          nm = df$alias_appended
        ),
      all_from_aliases = paste0(df$alias_alone, collapse = "|"),
      first_from_alias =
        set_names(
          x = paste(" as", first_statement$table, "\n"),
          nm = first_statement$alias_alone
        ),
      other_from_statements = c("123" = "\\1"), # placeholder
      confirm_statements = glue::glue("{df$alias} -> {df$table}")
    )

  if (nrow(other_statements)) {
    output$other_from_statements <-
      set_names(
        x = paste(" as", other_statements$table, ""),
        nm = other_statements$alias_alone
      )
  }

  output

}



#' function to replace aliases in code
#' called without arguments
#' @importFrom stringr str_remove_all str_replace_all
#' @importFrom stats na.omit
#' @examples
#' test_code(); replace_aliases()
replace_aliases <- function() {
  from_statement <- find_statement(statement = "the 'from' statements you want to use")
  from_text <- from_statement$selection[[1]]$text
  #cat(from_text)

  use_patterns <- find_alias_replacements(from_text)

  print(use_patterns$confirm_statements)
  ask_and_wait("Are these replacements correct? press [enter] to continue or [esc] to exit")

  # clear selection
  rstudioapi::setSelectionRanges(
    from_statement$selection[[1]]$range[[1]],
    id = from_statement$id
  )

  whole_query <- find_statement(statement = "your whole query")
  whole_query_text <- whole_query$selection[[1]]$text

  new_text <-
    whole_query_text %>%
    str_replace_all(use_patterns$first_from_alias) %>%
    str_replace_all(use_patterns$other_from_statements) %>%
    str_replace_all(na.omit(use_patterns$replace_appended)) %>%
    str_replace_all("(\\w)( +)(\\w)", "\\1 \\3")

  rstudioapi::modifyRange(
    location = whole_query$selection[[1]]$range,
    text = new_text,
    id = whole_query$id
  )
}
