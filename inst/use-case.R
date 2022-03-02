# setwd("~/github/sqlizer")
.devload()
folder <- system.file(package = "sqlizer")

setwd(folder)
.rs.api.filesPaneNavigate(folder)

open_sql_as_temp("")
open_sql_as_temp("")

replace_aliases()
dbtify()

