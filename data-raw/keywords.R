# from: https://raw.githubusercontent.com/jas502n/sqlmap-1/master/txt/keywords.txt
keywords <-
  readr::read_lines("data-raw/keywords.txt", skip_empty_rows = TRUE) |>
  tolower()

keywords <- keywords[!grepl("^#", keywords)]

usethis::use_data(keywords, overwrite = TRUE)
