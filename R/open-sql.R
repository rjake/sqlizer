#' open sql file in temp directory
#' @param file string of sql file location
#' @examples
#' open_sql_as_temp(file = "")
open_sql_as_temp <- function(file) {
  tmp <- tempfile(fileext = ".sql")
  file.copy(
    from = file,
    to = tmp
  )

  .rs.api.navigateToFile(tmp)
}


#' open demo sql file in temp directory
#' there are some files in the 'ref' folder but you can point this at any sql file
#' @param demo string of sample sql files to use
#' @examples
#' demo_sql()
#' demo_sql("rooms")
demo_sql <- function(demo = c("rooms", "reservations", "ortho-query")) {
  which_file <- match.arg(demo)

  sql <- paste0(which_file, ".sql")
  use_file <- system.file(file, package = "sqlizer")

  open_sql(use_file)
}
