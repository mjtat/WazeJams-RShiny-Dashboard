dedupe_and_format_waze <- function(queried_waze_df) {
  
  #' @description 
  #' This function takes queried waze jam data, and dedupes it (based on time stamps)
  #' then creates a set of date time variables (month, day, weekday label, hour, year, and week number)
  #' 
  #' @param queried_waze_df - a df of queried waze data.
  
  city <- as.vector(queried_waze_df$city[1])
  street <- as.vector(queried_waze_df$street[1])
  endNode <- as.vector(queried_waze_df$endNode[1])
  
  empty_uuids <- queried_waze_df %>% filter(uuid == '') %>% mutate(time_diff = endTime - startTime, 
                                                              month_startTime = month(startTime), 
                                                              day_startTime = day(startTime),
                                                              hour_startTime = hour(startTime),
                                                              minute_startTime = minute(startTime),
                                                              month_endTime = month(endTime), 
                                                              day_endTime = day(endTime),
                                                              hour_endTime = hour(endTime),
                                                              minute_endTime = minute(endTime),
                                                              start_end_diff = hour_endTime - hour_startTime)
  
  empty_uuids <- empty_uuids %>% group_by(day_startTime, hour_startTime) %>% 
    summarise(count = n(),
              speed = mean(speed, na.rm=TRUE),
              delay = mean(delay, na.rm=TRUE),
              startTime = min(startTime),
              endTime = max(endTime)) %>%
    mutate(n_jams = 1,
           city = city,
           street=street,
           endNode=endNode)
  
  empty_uuids$uuid <- sample(100000000000, size = nrow(empty_uuids), replace=TRUE)
  
  empty_uuids <- empty_uuids %>% ungroup(day_startTime) %>% select(-day_startTime)
  
  empty_uuids <- empty_uuids %>% ungroup(day_startTime, hour_startTime) %>% 
    select(city, street, endNode, uuid, count, n_jams, speed, delay, startTime, endTime) %>%
    mutate(uuid = as.character(uuid))
  
  examine_dedupe <- queried_waze_df %>% 
    filter(uuid != '') %>%
    group_by(city, street, endNode, uuid) %>% 
    summarise(count = n(),
              n_jams = 1,
              speed = mean(speed, na.rm=TRUE),
              delay = mean(delay, na.rm=TRUE),
              startTime = min(startTime), 
              endTime = max(endTime)) %>%
    mutate(uuid = as.character(uuid))
  
 examine_dedupe <- examine_dedupe %>% bind_rows(empty_uuids)
 
 examine_dedupe <- examine_dedupe %>%
   mutate(month=month(startTime, label = TRUE)) %>%
   mutate(day=day(startTime)) %>%
   mutate(weekday = wday(startTime, label = TRUE)) %>%
   mutate(hour=hour(startTime)) %>%
   mutate(year=year(startTime)) %>%
   mutate(week=week(startTime))
 
 return(examine_dedupe)

}

to_month_and_day <- function(waze_df, selected_month, selected_day) {
  
  #' @description  
  #' This function subsets the deduped waze dataframe into a specific month and specific date.
  #'
  #' @param waze_df - a dataframe of deduped waze jam data
  #' @param selected_month - a month, in 3-letter abbreviated format (e.g., Jan, Feb, Mar). Must be a character string.
  #' @param selected_day - a day of the month, an integer.
  
  
  hours_df <- tibble(hour_of_day = 1:24)
  
  waze_df <- waze_df %>% filter(month==selected_month,
                                day==selected_day)
  
  return(waze_df)
  
}