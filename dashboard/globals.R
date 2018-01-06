library(RODBC)
library(tidyverse)
library(leaflet)
library(leaflet.extras)
library(rgdal)
library(lubridate)
library(stringr)
library(shiny)
library(shinydashboard)
source('data_wrangling.R')
source('aggregation.R')
source('plotting.R')

conn_string <- read_lines('/home/michelle/michelle.tat/projects/Waze Dashboard/logins')

conn <- odbcDriverConnect(conn_string)

street_inventory <- read_csv('/home/michelle/michelle.tat/projects/Waze Dashboard/dashboard/data/jam_streets.csv')

primary_streets <- sort(unique(street_inventory$street))
end_node_street <- sort(unique(street_inventory$endNode))
years_list <- c('2015','2016','2017','2018')
months_list <- as.factor(c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))
date_list <- c(1:31)