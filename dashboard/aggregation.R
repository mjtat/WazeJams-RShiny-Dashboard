aggregate_daily_metrics <- function(daily_waze_df) {
  
  #' @description  
  #' This function groups subsetted daily waze data by hour of the day. It returns 
  #' numbers for reported jams, speed, and delays.
  #'
  #' @param daily_waze_df - a dataframe of waze data for a specific date. 
  
  hours_df <- tibble(hour_of_day = 0:23)
  
  waze_df <- daily_waze_df %>% group_by(hour) %>% 
    summarise(n_waze_reported_jams = n(),
              sd_speed = sd(speed),
              speed = mean(speed),
              mean_delay = mean(delay),
              sd_delay = sd(delay)) %>% 
    rename(hour_of_day = hour)
  
  waze_df <- waze_df %>% 
    right_join(hours_df, by='hour_of_day') %>% 
    replace_na(list(n_waze_reported_jams = 0,
                    sd_speed = 0,
                    speed = 0,
                    mean_delay = 0,
                    sd_delay = 0)) %>%
    mutate(hour_of_day = (hour_of_day + 1))
  
  
  
  return(waze_df)
  
}

aggregate_daily_average <- function(waze_df, waze_daily_df, selected_month, selected_day) {
  
  #' @description 
  #' This function creates a dataframe consisting of annual daily averages (all Mondays,
  #' for example), and the daily sums/averages for a single day (one Monday).
  #' 
  #' @param waze_df - a dataframe of deduped waze data
  #' @param waze_daily_df - a dataframe of one day's data, generated from aggregate_daily_metrics()
  #' @param selected_month - a specific month (e.g., 'Jan')
  #' @param selected_day - a specific date, integer (1,2,3,4 etc.)
  
  day_of_the_week <- waze_df %>% filter(month==selected_month, day==selected_day)
  day_of_the_week <- as.character(day_of_the_week$weekday[1])
  
  waze_df <- waze_df %>% mutate(n_jams = 1)
  
  waze_df <- waze_df %>% group_by(day, weekday, month) %>%
    summarise(jams = sum(n_jams),
              sd_speed = sd(speed),
              speed = mean(speed),
              mean_delay = mean(delay),
              sd_delay = sd(delay)) %>%
    filter(weekday==day_of_the_week)
  
  
  daily_summary_df <- tibble(category = 'Selected Date',
                             mean_total_jams = round(sum(waze_daily_df$n_waze_reported_jams)),
                             sd_jams = sd(waze_daily_df$n_waze_reported_jams),
                             sd_speed = mean(waze_daily_df$sd_speed, na.rm=TRUE),
                             speed = mean(waze_daily_df$speed, na.rm=TRUE),
                             mean_delay = mean(waze_daily_df$mean_delay, na.rm=TRUE),
                             sd_delay = mean(waze_daily_df$sd_delay, na.rm=TRUE))
  
  annual_summary_df <- tibble(category = 'Annual Average',
                              mean_total_jams = round(mean(waze_df$jams, na.rm=TRUE)),
                              sd_jams = sd(waze_df$jams, na.rm=TRUE),
                              sd_speed = mean(waze_df$sd_speed, na.rm=TRUE),
                              speed = mean(waze_df$speed, na.rm=TRUE),
                              mean_delay = mean(waze_df$mean_delay, na.rm=TRUE),
                              sd_delay = mean(waze_df$sd_delay, na.rm=TRUE))
  
  summary_df <- daily_summary_df %>% bind_rows(annual_summary_df)
  
  return(summary_df)
  
  
}

aggregate_weekly_metrics <- function(waze_df, selected_month, selected_day) {
  
  #' @description  
  #' This function groups subsetted daily waze data by hour of the day. It returns 
  #' numbers for reported jams, speed, and delays.
  #'
  #' @param waze_df - a dataframe of deduped waze data
  #' @param week_no - a week number, integer
  #' 
  
  week_number <- waze_df %>% filter(month==selected_month, day==selected_day) %>% select(week) %>% .[1,]
  
  that_week_waze_df <- waze_df %>% filter(month==selected_month, week==week_number)
  
  print(week_number)
  
  that_week_waze_df <- that_week_waze_df %>% group_by(weekday) %>% summarise(n_waze_reported_jams = n(),
                                                                             sd_speed = sd(speed),
                                                                             speed = mean(speed),
                                                                             mean_delay = mean(delay),
                                                                             sd_delay = sd(delay))
  
  return(that_week_waze_df)
  
}

aggregate_month_metrics <- function(waze_df, origin_date, number_of_days_back) {
  
  #' @description  
  #' This function groups subsetted daily waze data by each week of the month
  #'
  #' @param daily_waze_df - a dataframe of waze data for a specific date.
  
  start_date <- ymd(origin_date) - number_of_days_back
  
  waze_df <- waze_df %>% filter(ymd_hms(startTime) <= (ymd(origin_date)+1) & ymd_hms(startTime) >= start_date)
  
  waze_df <- waze_df %>% group_by(month, day, week, weekday) %>% summarise(n_waze_reported_jams = n(),
                                                                           sd_speed = sd(speed),
                                                                           speed = mean(speed),
                                                                           mean_delay = mean(delay),
                                                                           sd_delay = sd(delay))
  
  waze_df <- waze_df %>% arrange(month, day) %>%
    unite(date_label, weekday, month, day, sep = ' ')
  
  waze_df$index <- 1:nrow(waze_df)
  
  
  
  return(waze_df)
  
}