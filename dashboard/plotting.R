barplot_waze_metrics <- function(aggregated_waze_df, x_col, y_col, x_lab, y_lab) {
  
  #' @description  
  #' This function aggregated waze_data and generates a uniform bar plot.
  #'
  #' @param aggregated_waze_df - a data of aggregated waze data
  #' @param x_col - x-axis column
  #' @param y_col - y-axis column
  #' @param x_lab - a character string for the x axis label
  #' @param y_lab - a character string for the y axis label.
  
  
  p <- ggplot(data=aggregated_waze_df,aes(x=as.factor(x_col),y=y_col)) + 
    geom_bar(stat='identity',fill='#56B4E9') + 
    theme_minimal() + 
    labs(x=x_lab,y=y_lab) +
    geom_text(aes(label=y_col, vjust=-0.3), size=5) +
    theme(axis.text.x = element_text(size = 12), axis.text.y = element_text(size = 14),
          axis.title = element_text(size=14))
  
  return(p)
}

lineplot_waze_metrics <- function(waze_monthly_df, x_col, y_col, x_lab, y_lab) {
  
  #' @description 
  #' This function takes a dataframe of waze data *for a specific month* and creates a lineplot with it.
  #' 
  #' @param waze_monthly_df - a data of monthly waze data (e.g., october)
  #' @param x_col - x-axis column
  #' @param y_col - y-axis column
  #' @param factor_variable - factor for different lines on lineplot.
  #' @param x_lab - a character string for the x axis label
  #' @param y_lab - a character string for the y axis label.
  
  p <- ggplot(waze_monthly_df, aes(x=reorder(x_col, index), y=y_col, group = 1)) +
    geom_line(color='lightblue', size = 1.8) +
    geom_point(shape=19, size = 2.5, fill = 'black') +
    geom_text(aes(label = y_col, vjust=-.5), size = 5) +
    labs(x=x_lab, y=y_lab) +
    theme(axis.text.x = element_text(angle = 90, size = 14), axis.text.y = element_text(size = 14),
          axis.title = element_text(size=14))
  
  return(p)
  
}