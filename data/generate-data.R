library(data.table)
library(leaflet)
library(shiny)

# library(bootstraplib)
# bs_theme_new()
# # Color palette derives from https://tombrow.com/dark-mode-website-css
# bs_theme_base_colors(bg = "#444", fg = "#e4e4e4")
# bs_theme_accent_colors(primary = "#e39777", secondary = "#fdce93")
# shinyOptions(plot.autotheme = TRUE)
# bs_theme_preview()

# Ref: https://stackoverflow.com/questions/47064921/leaflet-legend-for-addawesomemarkers-function-with-icons
markerLegendHTML <- function(IconSet) {
  # container div:
  legendHtml <- "<div style='padding: 10px; padding-bottom: 10px;'><h4 style='padding-top:0; padding-bottom:10px; margin: 0;'> Confirmed </h4>"
  
  n <- 1
  # add each icon for font-awesome icons icons:
  for (Icon in IconSet) {
    if (Icon[["library"]] == "glyphicon") {
      legendHtml <- paste0(
        legendHtml,
        "<div style='width: auto; height: 45px'>",
        "<div style='position: relative; display: inline-block; width: 36px; height: 45px' class='awesome-marker awesome-marker-icon-",
        Icon[["markerColor"]],
        "'>",
        "<i style='margin-left: 4px; margin-top: 11px; color: ",
        Icon[["iconColor"]],
        "' class= 'glyphicon glyphicon-",
        Icon[["icon"]],
        "'></i>",
        "</div>",
        "<p style='position: relative; top: 10px; left: 2px; display: inline-block; ' >",
        names(IconSet)[n],
        "</p>",
        "</div>"
      )
    }
    n <- n + 1
  }
  paste0(legendHtml, "</div>")
}

popup_icons <- awesomeIconList(
  "0" = makeAwesomeIcon(icon = "stats", library = "glyphicon", markerColor = "green"),
  "1-100" = makeAwesomeIcon(icon = "stats", library = "glyphicon", markerColor = "lightblue"),
  "101-10000" = makeAwesomeIcon(icon = "stats", library = "glyphicon", markerColor = "orange"),
  "10001-100000" = makeAwesomeIcon(icon = "stats", library = "glyphicon", markerColor = "red"),
  "100001-1000000" = makeAwesomeIcon(icon = "stats", library = "glyphicon", markerColor = "black"),
  "1000000-" = makeAwesomeIcon(icon = "stats", library = "glyphicon", markerColor = "black", iconColor = "darkred")
)

# data <- readRDS(here::here('covid-19-data.RDS'))
datasource <- "jhu"
if (datasource == "datahub") {
  # https://datahub.io/core/covid-19, it's eventually CSSE data...
  json_file <- "https://datahub.io/core/covid-19/datapackage.json"
  json_data <- jsonlite::fromJSON(paste(readLines(json_file), collapse = ""))
  
  for (i in 1:length(json_data$resources$datahub$type)) {
    if (json_data$resources$datahub$type[i] == "derived/csv") {
      if (json_data$resources$name[i] == "time-series-19-covid-combined_csv") {
        path_to_file <- json_data$resources$path[i]
        data <- fread(path_to_file)
        break
      }
    }
  }
  data[, Date := as.Date(Date)]
  data[is.na(Recovered), Recovered := 0]
  data <- data[`Province/State` != "Recovered"]
  data[, DeathRate := Deaths / Confirmed]
  setnames(
    data,
    c("Country/Region", "Province/State", "Lat", "Long"),
    c("CountryName", "RegionName", "Latitude", "Longitude")
  )
} else if (datasource == "open-covid-19") {
  data <- fread("https://open-covid-19.github.io/data/data.csv")
  # select regional data
  data <- data[RegionName != "", ]
  data[, DeathRate := Deaths / Confirmed]
} else if (datasource == "jhu") {
  site_link <- paste0(
    "https://raw.githubusercontent.com/",
    "CSSEGISandData/COVID-19/",
    "master/csse_covid_19_data/",
    "csse_covid_19_time_series/"
  )
  confirmed_data <- fread(RCurl::getURL(paste0(site_link, "time_series_covid19_confirmed_global.csv")))
  recovered_data <- fread(RCurl::getURL(paste0(site_link, "time_series_covid19_recovered_global.csv")))
  death_data <- fread(RCurl::getURL(paste0(site_link, "time_series_covid19_deaths_global.csv")))
  
  # remove columns with NA's
  confirmed_data <- confirmed_data[
    , colSums(!is.na(confirmed_data)) == nrow(confirmed_data),
    with = FALSE
  ]
  recovered_data <- recovered_data[
    , colSums(!is.na(confirmed_data)) == nrow(confirmed_data),
    with = FALSE
  ]
  death_data <- death_data[
    , colSums(!is.na(confirmed_data)) == nrow(confirmed_data),
    with = FALSE
  ]
  
  cols <- names(recovered_data)[5:dim(recovered_data)[2]]
  recovered_data[, (cols) := lapply(.SD, as.integer), .SDcols = cols]
  
  confirmed <- melt(
    confirmed_data,
    id = 1:2,
    measure = colnames(confirmed_data)[3:dim(confirmed_data)[2]],
    value.factor = TRUE,
    variable.name = "Date",
    value.name = "Num"
  )
  recovered <- melt(
    recovered_data,
    id = 1:4,
    measure = colnames(recovered_data)[5:dim(recovered_data)[2]],
    value.factor = TRUE,
    variable.name = "Date",
    value.name = "Num"
  )
  death <- melt(
    death_data,
    id = 1:4,
    measure = colnames(death_data)[5:dim(death_data)[2]],
    value.factor = TRUE,
    variable.name = "Date",
    value.name = "Num"
  )
  
  confirmed = merge(
    confirmed, 
    recovered[, .(`Province/State`, `Country/Region`, Date, Lat, Long)],
    by = c('Province/State', 'Country/Region', 'Date'),
    all.x = TRUE
  )
  confirmed[, Type := "Confirmed"]
  recovered[, Type := "Recovered"]
  death[, Type := "Deaths"]
  
  data <- rbindlist(list(confirmed, recovered, death), fill = TRUE)
  data <- data[!is.na(data$Lat)]
  data[is.na(Num), Num := 0]
  data[, Date := lubridate::mdy(Date)]
  
  # data[`Country/Region`=='Taiwan*', `Province/State`:='Taiwan']
  # data[`Country/Region` %in% c('Mainland China', 'Taiwan*'), `Country/Region`:='China']
  # data[`Province/State` %in% c('Hong Kong', 'Macau'), `Country/Region`:='China']
  
  data <- dcast(data, ... ~ Type, value.var = "Num")
  data <- data[
    !(`Province/State` %in% c("Recovered", "Diamond Princess", "Grand Princess")) &
      !is.na(Confirmed) & !is.na(Deaths) & (Confirmed >= 0) & (Deaths >= 0)
  ]
  data[is.na(Recovered), Recovered := 0]
  
  # calculate current case: confirmed - death - recovered
  data[, `:=`(
    Current = Confirmed - Deaths - Recovered,
    DeathRate = Deaths / ifelse(Confirmed==0, 1, Confirmed)
  )]
  setnames(
    data,
    c("Country/Region", "Province/State", "Lat", "Long"),
    c("CountryName", "RegionName", "Latitude", "Longitude")
  )
  # colSums(is.na(data))
}

country_data <- data[, .(
  Confirmed = sum(Confirmed),
  Deaths = sum(Deaths)
), .(CountryName, Date)]

country_names <- c("World", unique(country_data[order(-Confirmed)][, CountryName]))

data[, `:=`(
  Date = as.Date(Date),
  icon_group = cut(
    data$Confirmed,
    breaks = c(-1, 0, 100, 10000, 100000, 1000000, 1000000000),
    labels = c("0", "1-100", "101-10000", "10001-100000", "100001-1000000", "1000000-")
  ),
  label = paste0(
    CountryName,
    " <br> ", RegionName,
    " <br> #Confirmed: ", Confirmed,
    " <br> #Deaths: ", Deaths
  )
)]
