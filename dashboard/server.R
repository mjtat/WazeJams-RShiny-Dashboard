shinyServer(function(input, output, session) { 
  
  output$end_node_select <- renderUI({
    
    selectInput("end_street",
                "Select End Street:",
                choices = sort(street_inventory$endNode[street_inventory$street==input$primary_corridor]))
    
  })
  
  street_name <- reactiveValues(data=NULL)
  the_end_node <- reactiveValues(data=NULL)
  year <- reactiveValues(data=NULL)
  custom_query <- reactiveValues(data=NULL)
  
  
  observeEvent(input$go, {
      street_name$data <- input$primary_corridor
      the_end_node$data <- input$end_street
      year$data <- input$year
      
      
  })
  
  
  myData <- eventReactive(input$go, {
    
    # Sample query which uses some input
    custom_query <- sprintf("SELECT DISTINCT jam.city,
                          jam.street,
                          jam.endNode,
                          jam.speed,
                          jam.delay,
                          jam.startTime AS endTime,
                          jam.endTime AS startTime,
                          jam.uuid
                          FROM Waze.dbo.Waze_JamData AS jam
                          WHERE city = 'Boston, MA' and street = '%s' and jam.endNode = '%s' and jam.startTime >= '%s-01-01 00:00:00' and jam.startTime <= '%s-12-31 00:00:00'
                          ORDER BY startTime ASC", street_name$data, the_end_node$data, year$data, year$data)
    
    # Storing results
    waze_query <- sqlQuery(conn, custom_query)
    
    street_coordinate <- sqlQuery(conn, sprintf("SELECT TOP 30 jam.street, 
                              jam.endNode, 
                              point.x, 
                              point.y
                              FROM dbo.Waze_JamData AS jam
                              INNER JOIN dbo.Waze_PointData AS point
                              ON jam.uuid=point.uuid
                              WHERE jam.street='%s' and jam.endNode = '%s'", street_name$data, the_end_node$data))
    
    # Clean and dedupe the data
    waze_query <- dedupe_and_format_waze(waze_query)
    
    waze_df <- to_month_and_day(waze_query, input$month_list, input$date_list)
    
    waze_daily <- aggregate_daily_metrics(waze_df)
    
    waze_daily_avg <- aggregate_daily_average(waze_query, waze_daily, input$month_list, input$date_list)
    
    the_date <- paste0(input$year, '-', input$month_list, '-', input$date_list)
    
    the_date <- as.character(ymd(the_date))
    
    waze_monthly <- aggregate_month_metrics(waze_query, the_date, as.numeric(input$date_range))
    
    plot1 <- barplot_waze_metrics(waze_daily, 
                                  waze_daily$hour_of_day, 
                                  waze_daily$n_waze_reported_jams,  
                                  'Hour of Day', 
                                  'Number of Reported Jams')
    
    plot2 <- barplot_waze_metrics(waze_daily_avg,
                                  waze_daily_avg$category,
                                  waze_daily_avg$mean_total_jams,
                                  'Daily or Annual',
                                  'Number of Jams')
    
    
    
    plot3 <- lineplot_waze_metrics(waze_monthly,
                                   waze_monthly$date_label,
                                   waze_monthly$n_waze_reported_jams,
                                   "Date",
                                   "Number of Reported Jams")
    
    map <- leaflet(street_coordinate) %>% 
      addPolylines(lng=~x, 
                   lat=~y, 
                   opacity = 1, 
                   noClip=TRUE, 
                   stroke=1,
                   popup= paste0("<b>Date: <b>", paste0(the_date), "</b><br>") %>% 
      addProviderTiles(providers$Stamen.Toner))
    
    # Returning results
    combo <- list(a = waze_query, 
                  b = waze_df, 
                  c = waze_daily, 
                  d = waze_daily_avg,
                  e = plot1,
                  f = plot2,
                  g = plot3,
                  h = the_date,
                  i = map)
    
    combo
    
  })
  
  observeEvent(input$reset, {
    street_name <- reactiveValues(data=NULL)
    the_end_node <- reactiveValues(data=NULL)
    year <- reactiveValues(data=NULL)
    custom_query <- reactiveValues(data=NULL)
    
  })
  
  
  output$text <- renderText({myData()$h})
  output$text1 <- renderText({the_end_node$data})
  output$text2 <- renderText({custom_query$data})
  output$table <- renderDataTable({combo <- myData()$a})
  output$plot1 <- renderPlot({print(myData()$e)})
  output$plot2 <- renderPlot({print(myData()$f)})
  output$plot3 <- renderPlot({print(myData()$g)})
  output$map <- renderLeaflet(myData()$i)
  
})