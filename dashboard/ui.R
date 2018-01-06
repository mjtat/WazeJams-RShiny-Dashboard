dashboardPage(skin = 'black',
  dashboardHeader(title = 'Test Dash'),
  
  dashboardSidebar(
                  sidebarMenu(
                              box(
                                title = "Choose Corridors and Dates",
                                width = 14,
                                background = "black",
                                
                                selectInput("primary_corridor",
                                            "Select Primary Corridor:",
                                             choices =  primary_streets),
                                
                                uiOutput("end_node_select"),
                                
                                selectInput("year",
                                            "Select Data For Specific Year:",
                                            choices = years_list),
                                
                                selectInput("month_list",
                                            "Select Data For Specific Month:",
                                            choices = months_list),
                                
                                selectInput("date_list",
                                            "Select Data For Specific Day:",
                                            choices = date_list),
                                
                                selectInput("date_range",
                                            "Select Number of Days Back to Examine:",
                                            choices = c(7,14,21,28,35,42,49)),
                                
                                actionButton("go", "Submit"),
                                actionButton("reset", "Reset Data Inputs")
                                )
      
                              )
                      
                            ),
  
  dashboardBody(tags$style(type="text/css",
                           ".shiny-output-error { visibility: hidden; }",
                           ".shiny-output-error:before { visibility: hidden; }"),
                
                tabsetPanel(type = "tabs",
                            tabPanel("Figures for Metrics", box(align = "left", plotOutput("plot1"), width = 8),
                                                            box(align = "right", plotOutput("plot2"), width = 4),
                                                            box(align = "center", plotOutput("plot3"), width = 12, height = 15)),
                            tabPanel("Map", leafletOutput("map", height = 800 )),
                            tabPanel("Data Table", dataTableOutput("table")))
                
                #dataTableOutput("table"))
  )
)