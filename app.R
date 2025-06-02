library(shiny)
library(bslib)
library(shinydashboard)
library(data.table)
library(leaflet)
library(leaflet.extras)
library(DT)
library(RCurl)
library(leafem)
library(shinycssloaders)
library(plotly)

# ─── 1. Create a bs_theme with your fonts/colors ───────────────────────────────
my_theme <- bs_theme(
    version      = 5,
    bootswatch   = "minty",
    base_font    = font_google("Open Sans"),
    heading_font = font_google("Roboto Slab")
)

# ─── 2. Define UI ──────────────────────────────────────────────────────────────
ui <- dashboardPage(
    title = "COVID-19 Shiny App",
    skin = "red",
    
    dashboardHeader(
        title = span(icon("virus"), "COVID-19 Dashboard"),
        
        # Header links
        tags$li(class = "dropdown", actionLink(inputId = "go_home",       label = tagList(icon("home"),         "Home"))),
        tags$li(class = "dropdown", actionLink(inputId = "go_dashboard1", label = tagList(icon("tachometer-alt"), "Interactive Map"))),
        tags$li(class = "dropdown", actionLink(inputId = "go_dashboard2", label = tagList(icon("chart-line"),    "Interactive Charts"))),
        tags$li(class = "dropdown", tags$a(href = "https://github.com/tunglambg131003/data_visualization_project_2", icon("info-circle"), "About"))
    ),
    
    dashboardSidebar(
        width = 260,
        uiOutput("sidebar_ui")
    ),
    
    dashboardBody(
        theme = my_theme,
        
        # Dynamically inject CSS to hide sidebar on Home
        uiOutput("sidebar_css"),
        
        tags$head(
            tags$link(rel = "icon", type = "image/png", href = "logo.png"),
            
            tags$style(HTML("
        .box { box-shadow: 0 2px 5px rgba(0,0,0,0.15); }
        .value-box { font-size: 18px; color: black }
        .main-header .logo { font-size: 20px; }
        .small-box { border-radius: 2px; position: relative; display: block }
        .inner { color: black !important; }
        .main-header .sidebar-toggle { display: none !important; }
      "))
        ),
        
        # Placeholder for Home, Dashboard1, or Dashboard2
        uiOutput("body_ui")
    )
)

# ─── 3. Define Server ─────────────────────────────────────────────────────────
server <- function(input, output, session) {
    # 3.1 Track current page: set initial to "home"
    current_page <- reactiveVal("home")
    
    observeEvent(input$go_home,       { current_page("home") })
    observeEvent(input$go_dashboard1, { current_page("dashboard1") })
    observeEvent(input$go_dashboard2, { current_page("dashboard2") })
    
    # 3.2 Inject CSS to hide the sidebar when on Home
    output$sidebar_css <- renderUI({
        if (current_page() == "home") {
            tags$style(HTML("
        /* Hide the left‐hand sidebar completely */
        .main-sidebar { display: none !important; }
        /* Remove left margin so content fills full width */
        .content-wrapper, .right-side { margin-left: 0 !important; }
      "))
        } else {
            NULL
        }
    })
    
    # 3.3 Render conditional sidebar UI
    output$sidebar_ui <- renderUI({
        switch(
            current_page(),
            
            "home" = {
                NULL
            },
            
            "dashboard1" = {
                tagList(
                    br(),
                    div(
                        class = "compact-slider",
                        style = "width:250px;",
                        sliderInput(
                            "date1", "Select Date:",
                            min     = min(data$Date),
                            max     = max(data$Date),
                            value   = max(data$Date),
                            animate = animationOptions(interval = 1500, loop = TRUE)
                        )
                    ),
                    selectInput(
                        "country1", "Select Country",
                        choices  = country_names,
                        selected = "World"
                    ),
                    radioButtons(
                        "severity1", "Confirmed Cases Range:",
                        choices = list(
                            "All"               = "all",
                            "1–100"             = "1-100",
                            "101–10,000"        = "101-10000",
                            "10,001–100,000"    = "10001-100000",
                            "100,001–1,000,000" = "100001-1000000",
                            "1,000,000+"        = "1000000-"
                        ),
                        selected = "all"
                    )
                )
            },
            
            "dashboard2" = {
                tagList(
                    br(),
                    selectizeInput(
                        "ts_countries", "Select Countries:",
                        choices  = setdiff(country_names, "World"),  # exclude "World"
                        selected = country_names[2],
                        multiple = TRUE,
                        options  = list(maxItems = 5, placeholder = 'Up to 5 countries')
                    ),
                    div(
                        style = "width:250px; margin-top: 15px;",
                        sliderInput(
                            "ts_dates", "Select Date Range:",
                            min   = min(data$Date),
                            max   = max(data$Date),
                            value = c(min(data$Date), max(data$Date)),
                            timeFormat = "%b %d, %Y",
                            step = 1,
                            ticks = FALSE
                        )
                    )
                )
            }
        )
    })
    
    # 3.4 Reactive subset of data for Dashboard1
    sub_data1 <- reactive({
        req(input$date1, input$country1, input$severity1)
        if (input$country1 == "World" && input$severity1 == "all") {
            data[Date == input$date1]
        } else if (input$country1 == "World" && input$severity1 != "all") {
            data[Date == input$date1 & icon_group == input$severity1]
        } else if (input$country1 != "World" && input$severity1 == "all") {
            data[Date == input$date1 & CountryName == input$country1]
        } else {
            data[Date == input$date1 & CountryName == input$country1 & icon_group == input$severity1]
        }
    })
    
    # 3.5 Reactive time-series data for Dashboard2
    ts_data2 <- reactive({
        req(input$ts_countries, input$ts_dates)
        data[
            CountryName %in% input$ts_countries &
                Date >= input$ts_dates[1] & Date <= input$ts_dates[2],
            .(CountryName, Date, Confirmed, Recovered, Deaths)
        ]
    })
    
    # ── 3.5.1 Reactive summary (totals) for each country in ts_data2
    summary_data2 <- reactive({
        req(ts_data2())
        df <- ts_data2()
        
        # Get the last day for each country and extract corresponding values
        df[order(Date), .SD[.N], by = CountryName][, .(
            CountryName,
            TotalConfirmed = Confirmed,
            TotalRecovered = Recovered,
            TotalDeaths    = Deaths
        )]
    })
    
    ts_new_cases2 <- reactive({
        req(ts_data2())
        
        df <- ts_data2()
        
        # Step 1: Aggregate by country and date
        df_agg <- df[, .(Confirmed = sum(Confirmed, na.rm = TRUE)), by = .(CountryName, Date)]
        setorder(df_agg, CountryName, Date)
        
        # Step 2: Calculate NewConfirmed
        df_agg[, NewConfirmed := Confirmed - shift(Confirmed, 1), by = CountryName]
        df_agg[is.na(NewConfirmed) | NewConfirmed < 0, NewConfirmed := 0]
        df_agg[NewConfirmed > 1e6, NewConfirmed := NA]
        
        df_agg
    })
    
    
    # ── 3.6 Render UI: show Home, Dashboard1, or Dashboard2
    output$body_ui <- renderUI({
        switch(
            current_page(),
            
            "home" = {
                fluidPage(
                    tags$head(
                        tags$style(HTML("
        .center-text {
            text-align: center;
        }
        .info-section {
            background-color: #f9f9f9;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 35px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        }
        .image-box {
            text-align: center;
            margin-top: 20px;
        }
        .image-box img {
            max-width: 100%;
            height: auto;
            border-radius: 10px;
        }
    "))
                    ),
                    
                    br(),
                    div(class = "info-section",
                        h2(
                            tagList(
                                icon("handshake", class = "fa-lg", style = "margin-right: 10px; color: #2c3e50;"),
                                "Welcome to our Shiny App"
                            ),
                            class = "center-text"
                        ),
                        p("This product is designed to serve as a dynamic, data-driven platform for tracking and analyzing the COVID-19 pandemic from John Hopkins University (JHU) Dataset. Drawing upon real-time data sourced from globally recognized institutions, it enables users to explore comprehensive metrics, trends, and insights regarding the spread and impact of the virus across different regions and time periods.", class = "center-text"),
                        p("Whether you are a researcher, policymaker, student, or concerned citizen, this tool aims to enhance your understanding of the pandemic through a combination of interactive visualizations and curated information.")
                    ),
                    
                    div(class = "info-section",
                        h3("🌍 What is COVID-19?", class = "center-text"),
                        div(class = "image-box",
                            img(src = "https://www.cetim.ch/wp-content/uploads/Pages-2-et-3-1.png", alt = "COVID-19 Image")
                        ),
                        br(),
                        p("Coronavirus Disease 2019 (COVID-19) is a highly infectious respiratory illness caused by the novel coronavirus SARS-CoV-2. First emerging in December 2019 in Wuhan, China, the virus quickly evolved into a global pandemic, disrupting healthcare systems, economies, and societies on an unprecedented scale.", style = "text-align: justify;"),
                        
                        p("Primarily transmitted through respiratory droplets and aerosols, COVID-19 affects the human respiratory tract, with clinical presentations ranging from asymptomatic infection to critical illness involving pneumonia, acute respiratory distress syndrome, and multi-organ failure. High-risk populations—such as the elderly, immunocompromised individuals, and those with underlying comorbidities—have experienced disproportionately severe outcomes.", style = "text-align: justify;"),
                        
                        
                        div(class = "image-box",
                            h4("COVID-19 Spread Simulation", style = "margin-bottom: 10px;"),
                            img(src = "covid_simulation.gif", 
                                alt = "COVID-19 Spread Simulation", 
                                style = "max-width: 100%; height: auto; border-radius: 10px; margin-top: 20px;")
                        ), 
                        
                        p("Governments and health agencies worldwide have employed a range of public health interventions, including lockdowns, travel restrictions, vaccination campaigns, and contact tracing, to curb the virus’s spread. These efforts, alongside unprecedented vaccine development and deployment, represent a historic global response to a public health emergency.", style = "text-align: justify; margin-top: 20px"),
                        
                        
                        div(class = "image-box",
                            h4("COVID-19 Spread Simulation with forced quarantine", style = "margin-bottom: 10px;"),
                            img(src = "covid_gate.gif", 
                                alt = "COVID-19 Spread Simulation with forced quarantine", 
                                style = "max-width: 100%; height: auto; border-radius: 10px; margin-top: 20px;")
                        ),
                        p("For authoritative information and updates, please refer to the ",
                          tags$a(href = "https://www.who.int/emergencies/diseases/novel-coronavirus-2019", "World Health Organization’s COVID-19 Portal", target = "_blank"), ".", style = "text-align: justify; margin-top: 20px")
                    ),
                    
                    div(class = "info-section",
                        h3("📊 Our Features", class = "center-text"),
                        p("The dashboard comprises two major components, each designed to present key facets of the pandemic through distinct visualizations and analytical perspectives:"),
                        tags$ul(
                            tags$li(
                                strong("Interactive Map:"), 
                                " A real-time overview featuring an interactive global map and a customizable data table. Users can drill down by region or country to examine specific case numbers, testing rates, vaccination coverage, and other indicators."
                            ),
                            tags$li(
                                strong("Interactive Charts:"), 
                                " A longitudinal dashboard offering time-series visualizations of confirmed cases, recoveries, and fatalities. This view facilitates the analysis of pandemic waves, intervention impacts, and country-specific trajectories."
                            )
                        ),
                        p("Each allows for granular interaction, filter customization, and comparative insights. These tools are ideal for conducting longitudinal studies, supporting academic research, or developing policy briefs based on evidence-based metrics."),
                        div(class = "center-text", style = "margin-top: 20px;",
                            actionLink("go_dashboard1", label = strong("→ Enter Interactive Map ←")),
                            span("   "),
                            actionLink("go_dashboard2", label = strong("→ Enter Interactive Charts ←"))
                        )
                    ),
                    
                    div(class = "info-section",
                        h3("🔍 Interaction and Insight", class = "center-text"),
                        p("After navigating away from this Home section, users retain access to filtering tools and dynamic controls across dashboards. This persistent interactivity ensures that your exploration remains fluid and uninterrupted, allowing for tailored analyses based on country, time frame, population demographics, and health system indicators."),
                        p("We invite you to explore the data critically and constructively, fostering a deeper understanding of this ongoing global challenge.")
                    )
                )
            }
            
            ,
            
            "dashboard1" = {
                tagList(
                    fluidRow(
                        valueBoxOutput("confirmedBox1"),
                        valueBoxOutput("deathBox1"),
                        valueBoxOutput("rateBox1"),
                        valueBoxOutput("recoveredBox1"),
                        valueBoxOutput("locationBox1"),
                        valueBoxOutput("dateBox1")
                    ),
                    
                    fluidRow(
                        box(
                            title       = tagList(icon("map-marked-alt"), "Interactive Map"),
                            width       = 8,
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            status      = "primary",
                            withSpinner(leafletOutput("leaflet_map1", height = 500), type = 6)
                        ),
                        box(
                            title       = tagList(icon("table"), "Information Table"),
                            width       = 4,
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            status      = "info",
                            div(
                                style = "overflow-x:auto; width:100%; height:500px;",
                                withSpinner(DTOutput("table1"), type = 6)
                            )
                        )
                    )
                )
            },
            
            "dashboard2" = {
                # ─── NEW: Dashboard 2 with 3 charts ───────────────────────────────────────
                fluidPage(
                    fluidRow(
                        box(
                            title       = tagList(icon("chart-line"), "COVID-19 Confirmed Cases, Recovered, and Deaths Trend"),
                            width       = 12,
                            status      = "info",
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            withSpinner(plotlyOutput("ts_plot2", height = "350px"), type = 6)
                        )
                    ),
                    
                    fluidRow(
                        # Pie chart: distribution of total Confirmed by country
                        box(
                            title       = tagList(icon("chart-pie"), "Total Confirmed Cases"),
                            width       = 6,
                            status      = "warning",
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            withSpinner(plotlyOutput("pieChart2", height = "350px"), type = 6)
                        ),
                        # Bar chart: side‐by‐side totals of Confirmed/Recovered/Deaths
                        box(
                            title       = tagList(icon("chart-bar"), "Totals by Country"),
                            width       = 6,
                            status      = "primary",
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            withSpinner(plotlyOutput("barChart2", height = "350px"), type = 6)
                        )
                    ),
                    
                    fluidRow(
                        box(
                            title       = tagList(icon("chart-bar"), "Daily New Confirmed Cases"),
                            width       = 12,
                            status      = "warning",
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            withSpinner(plotlyOutput("new_cases_plot2", height = "400px"), type = 6)
                        )
                    )
                )
            }
        )
    })
    
    # ── 3.7 Value Boxes for Dashboard1
    output$confirmedBox1 <- renderValueBox({
        df <- sub_data1()
        total <- sum(as.numeric(df$Confirmed), na.rm = TRUE)
        valueBox(
            format(total, big.mark = ","), 
            "Confirmed Cases", 
            icon = icon("vial"), 
            color = "yellow"
        )
    })
    output$deathBox1 <- renderValueBox({
        df <- sub_data1()
        total <- sum(as.numeric(df$Deaths), na.rm = TRUE)
        valueBox(
            format(total, big.mark = ","), 
            "Number of Deaths", 
            icon = icon("skull-crossbones"), 
            color = "red"
        )
    })
    output$recoveredBox1 <- renderValueBox({
        df <- sub_data1()
        total <- sum(as.numeric(df$Recovered), na.rm = TRUE)
        valueBox(
            format(total, big.mark = ","), 
            "Number of Recovered", 
            icon = icon("heart"), 
            color = "green"
        )
    })
    output$rateBox1 <- renderValueBox({
        df <- sub_data1()
        confirmed <- sum(as.numeric(df$Confirmed), na.rm = TRUE)
        deaths    <- sum(as.numeric(df$Deaths),    na.rm = TRUE)
        rate      <- deaths / max(1, confirmed) * 100
        valueBox(
            paste0(sprintf("%.2f", rate), "%"),
            "Death Rate",
            icon  = icon("chart-bar"),
            color = "aqua"
        )
    })
    output$locationBox1 <- renderValueBox({
        valueBox(
            input$country1,
            "Location",
            icon  = icon("globe-americas"),
            color = "teal"
        )
    })
    output$dateBox1 <- renderValueBox({
        valueBox(
            input$date1,
            "Date",
            icon  = icon("calendar-day"),
            color = "blue"
        )
    })
    
    # ── 3.8 Leaflet Map for Dashboard1
    output$leaflet_map1 <- renderLeaflet({
        init_df <- sub_data1()
        
        m <- leaflet(options = leafletOptions(minZoom = 2, maxZoom = 8)) %>%
            addProviderTiles(providers$CartoDB.Positron) %>%
            leafem::addHomeButton(
                raster::extent(c(-130, 130, -50, 50)),
                "Home",
                position = "topleft"
            ) %>%
            addFullscreenControl(position = "topleft")
        
        if (nrow(init_df) > 0) {
            init_df[, label := paste0(
                "<strong>Country:</strong> ", CountryName, "<br/>",
                "<strong>Region:</strong> ", fifelse(is.na(RegionName) | RegionName == "", "N/A", RegionName),
                "<br/><strong>Date:</strong> ", Date, "<br/>",
                "<strong>Confirmed:</strong> ", Confirmed, "<br/>",
                "<strong>Recovered:</strong> ", Recovered, "<br/>",
                "<strong>Deaths:</strong> ", Deaths
            )]
            
            m <- m %>%
                addAwesomeMarkers(
                    data  = init_df,
                    lng   = ~Longitude,
                    lat   = ~Latitude,
                    label = ~lapply(label, htmltools::HTML),
                    icon  = ~popup_icons[icon_group],
                    group = "covid-19"
                ) %>%
                addControl(
                    html = HTML("
            <div style='padding:10px; padding-bottom:10px;'>
              <h4 style='padding-top:0; padding-bottom:10px; margin:0;'> Confirmed </h4>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-green'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>0</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-lightblue'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>1-100</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-orange'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>101-10000</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-red'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>10001-100000</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-black'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>100001-1000000</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-darkred'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>1000000-</p>
              </div>
            </div>
          "),
                    position = "bottomright"
                )
        }
        
        if (input$country1 == "World") {
            m <- setView(m, lng = 0, lat = 0, zoom = 2)
        } else if (nrow(init_df) > 0) {
            loc <- init_df[1]
            m <- setView(m, lng = loc$Longitude, lat = loc$Latitude, zoom = 4)
        }
        
        m
    })
    
    # 3.9 Observe changes in sub_data1() to update markers via leafletProxy
    observeEvent(sub_data1(), {
        leaflet_data <- sub_data1()
        
        leafletProxy("leaflet_map1", data = leaflet_data) %>%
            clearMarkers() %>%
            clearControls()
        
        if (nrow(leaflet_data) > 0) {
            leaflet_data[, label := paste0(
                "<strong>Country:</strong> ", CountryName, "<br/>",
                "<strong>Region:</strong> ",
                fifelse(is.na(RegionName) | RegionName == "", "N/A", RegionName),
                "<br/><strong>Date:</strong> ", Date, "<br/>",
                "<strong>Confirmed:</strong> ", Confirmed, "<br/>",
                "<strong>Recovered:</strong> ", Recovered, "<br/>",
                "<strong>Deaths:</strong> ", Deaths
            )]
            
            leafletProxy("leaflet_map1", data = leaflet_data) %>%
                addAwesomeMarkers(
                    lng   = ~Longitude,
                    lat   = ~Latitude,
                    label = ~lapply(label, htmltools::HTML),
                    icon  = ~popup_icons[icon_group],
                    group = "covid-19"
                ) %>%
                addControl(
                    html = HTML("
            <div style='padding:10px; padding-bottom:10px;'>
              <h4 style='padding-top:0; padding-bottom:10px; margin:0;'> Confirmed </h4>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-green'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>0</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-lightblue'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>1-100</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-orange'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>101-10000</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-red'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>10001-100000</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-black'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>100001-1000000</p>
              </div>
              
              <div style='width:auto; height:45px'>
                <div style='position:relative; display:inline-block; width:36px; height:45px'
                     class='awesome-marker awesome-marker-icon-darkred'>
                  <i style='margin-left:4px; margin-top:11px; color:white'
                     class='glyphicon glyphicon-stats'></i>
                </div>
                <p style='position:relative; top:10px; left:2px; display:inline-block;'>1000000-</p>
              </div>
            </div>
          "),
                    position = "bottomright"
                ) %>%
                {
                    if (input$country1 == "World") {
                        setView(., lng = 0, lat = 0, zoom = 2)
                    } else {
                        loc <- leaflet_data[1]
                        setView(., lng = loc$Longitude, lat = loc$Latitude, zoom = 4)
                    }
                }
        }
    })
    
    # ── 3.10 DataTable for Dashboard1
    output$table1 <- renderDataTable({
        df <- sub_data1()[
            , .(
                Country   = CountryName,
                Region    = RegionName,
                Confirmed,
                Recovered,
                Deaths,
                DeathRate
            )
        ][order(-Confirmed)]
        
        datatable(
            df,
            rownames = FALSE,
            options  = list(
                pageLength = 10,
                autoWidth  = TRUE,
                scrollX    = TRUE,
                dom        = '<"top table-controls"lf>rt<"bottom"ip><"clear">'
            ),
            class = "display nowrap compact"
        ) %>%
            formatPercentage("DeathRate", 2)
    })
    
    # ── 3.11 Time-series plot for Dashboard2 (unchanged)
    output$ts_plot2 <- renderPlotly({
        df <- ts_data2()
        validate(
            need(nrow(df) > 0, "No data available for the selected countries/date range.")
        )
        
        p <- plot_ly()
        for (country in unique(df$CountryName)) {
            dfc <- df[CountryName == country]
            # Confirmed (solid line)
            p <- p %>%
                add_lines(
                    data = dfc, x = ~Date, y = ~Confirmed,
                    name = paste(country, "- Confirmed"),
                    mode = "lines"
                )
            # Recovered (dashed line)
            p <- p %>%
                add_lines(
                    data = dfc, x = ~Date, y = ~Recovered,
                    name = paste(country, "- Recovered"),
                    mode = "lines",
                    line = list(dash = "dash")
                )
            # Deaths (dotted line)
            p <- p %>%
                add_lines(
                    data = dfc, x = ~Date, y = ~Deaths,
                    name = paste(country, "- Deaths"),
                    mode = "lines",
                    line = list(dash = "dot")
                )
        }
        
        p %>%
            layout(
                title = paste(
                    "COVID-19 Confirmed, Recovered & Deaths Trends for",
                    paste(input$ts_countries, collapse = ", ")
                ),
                xaxis = list(title = "Date"),
                yaxis = list(title = "Value"),
                hovermode = "x unified"
            )
    })
    
    # ── 3.12 NEW: Pie chart of total Confirmed per country
    output$pieChart2 <- renderPlotly({
        df_sum <- summary_data2()
        validate(
            need(nrow(df_sum) > 0, "No summary data available for the selected range.")
        )
        
        plot_ly(
            data = df_sum,
            labels = ~CountryName,
            values = ~TotalConfirmed,
            type = "pie",
            textinfo = "label+percent",
            hoverinfo = "label+value"
        ) %>%
            layout(
                title = paste("Total Confirmed Cases ", "on ", 
                              format(input$ts_dates[2], "%Y-%m-%d"), sep = "")
            )
    })
    
    # ── 3.13 NEW: Bar chart of totals (Confirmed, Recovered, Deaths) per country
    output$barChart2 <- renderPlotly({
        df_sum <- summary_data2()
        validate(
            need(nrow(df_sum) > 0, "No summary data available for the selected range.")
        )
        
        # Melt into long format for grouped bars
        df_long <- melt(
            df_sum,
            id.vars = "CountryName",
            measure.vars = c("TotalConfirmed", "TotalRecovered", "TotalDeaths"),
            variable.name = "Metric",
            value.name = "Count"
        )
        # Rename Metric levels for nicer axis text
        df_long[, Metric := fifelse(
            Metric == "TotalConfirmed", "Confirmed",
            fifelse(Metric == "TotalRecovered", "Recovered", "Deaths")
        )]
        
        plot_ly(
            data = df_long,
            x = ~CountryName,
            y = ~Count,
            color = ~Metric,
            type = "bar"
        ) %>%
            layout(
                barmode = "group",
                title = paste("Totals by Country ", "on ", 
                              format(input$ts_dates[2], "%Y-%m-%d"), sep = ""),
                xaxis = list(title = "Country"),
                yaxis = list(title = "Value")
            )
    })
    
    output$new_cases_plot2 <- renderPlotly({
        df <- ts_new_cases2()
        
        p <- ggplot(df, aes(x = Date, y = NewConfirmed, color = CountryName, group = CountryName)) +
            geom_line(size = 1) +
            geom_point(size = 1, alpha = 0.7) +
            labs(
                title = "Daily New Confirmed COVID-19 Cases",
                x = "Date", y = "Number of New Cases", color = "Country"
            ) +
            theme_minimal(base_size = 14)
        
        ggplotly(p) %>% layout(legend = list(orientation = "h", x = 0.1, y = -0.2))
    })
    
}

shinyApp(ui, server)
