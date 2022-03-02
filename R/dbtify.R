#' convert from statement to source & ref
#' called without arguments
#' @importFrom stringr str_remove_all str_replace_all
#' @importFrom stats na.omit
#' @importFrom rstudioapi setSelectionRanges modifyRange
#' @examples
#' jinjify()
jinjify <- function(sources_path = "etl/sources.yml") {
  from_statement <- find_statement(statement = "the 'from' statements you want to use")
  from_text <- from_statement$selection[[1]]$text
  #cat(from_text)

  use_patterns <- source_replacements(sources_path)

  new_text <-
    str_replace_all(from_text, use_patterns)# |>
    #str_replace_all(" {2,}", " ") |>
    #str_replace_all(" on ", "\n        on ")

  cat(new_text)

  ask_and_wait("Are these replacements correct? press [enter] to continue or [esc] to exit")

  # clear selection

  rstudioapi::modifyRange(
    location = from_statement$selection[[1]]$range,
    text = new_text,
    id = from_statement$id
  )
}

# #' @importFrom glue glue
# #' @examples
# #' table_regex(db = "data_base.schema.table_name")
# table_regex <- function(db, schema = "\\w+", table = "\\w+") {
#   glue("({db})\\.({schema})?\\.({table})") |>
#     as.character()
# }

# #' @importFrom glue glue
# #' @examples
# #' jinja_syntax(x = "ref")
# jinja_syntax <- function(x) {
#   find_sources
#
#   ifelse(
#     test = x == "ref",
#     yes = "{{ref('\\3')}} as \\3",
#     no = glue("{{source('[x]', '\\3')}} as \\3", .open = "[", .close = "]")
#   )  |>
#     as.character()
# }

#' Identify the sources from a sources yml file
#' @importFrom yaml read_yaml
#' @importFrom tibble tibble
#' @importFrom purrr map_chr map pluck
#' @importFrom stringr str_remove_all
#' @importFrom tidyr unnest unnest_wider
#' @importFrom dplyr select rename mutate_all
#' @examples
#' find_sources()
find_sources <- function(path = "etl/sources.yml") {
  raw_sources <- yaml::read_yaml(path)
  sources <- raw_sources$sources

  tibble(
    source = map_chr(sources, pluck, "name"),
    db =
      map_chr(sources, pluck, "database") |>
      str_remove_all(".*, '|'\\).*"),
    schema = map_chr(sources, pluck, "schema"),
    tables = map(sources, pluck, "tables")
  ) |>
    unnest(tables) |>
    unnest_wider(tables) |>
    select(-identifier) |>
    rename(table = name) |>
    mutate_all(tolower)
}


#' Glue using square brackets
#' @importFrom glue glue
#' @examples
#' glue_b(x = "ref")
glue_b <- function(...) {
  glue(..., .open = "[", .close = "]", .envir = rlang::caller_env()) |>
    as.character()
}

#' Generate regex replacements for tables found in sources.yml
#' @importFrom dplyr mutate
#' @importFrom purrr set_names
#' @examples
#' source_replacements()
source_replacements <- function(path) {
  df <-
    find_sources(path) |>
    mutate(
      pattern = glue_b("[db]\\.([schema]|admin)?\\.([table])"),
      replacement = glue_b("{{source('[source]', '[table]')}}")
    )

  # append(
    # set_names(ref, "{{ref('\\1')}} as \\1"),
    set_names(df$pattern, df$replacement)
  # )
}


