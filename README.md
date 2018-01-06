RShiny Dashboard For Waze Data
--------------------------------

Originally, this code was used as a skeleton to build out a RShiny dashboard used
to visualize Waze traffic jam data. Your organization must be a Waze CCP and have
access to the API in order to use/modify this dashboard to work.

In the current form of this dashboard, an end user would choose a corridor that
they wanted to examine (examples in this dashboard are specific to Boston, MA only),
the cross street (or what's called an "End Node"), and the specific day, time, and year.

The end user also chooses how many days to look back from the specified day, in order
to understand historical information

The dashboard will then visualize the following:
* For that day, the number of jams (or average speed in each jam) on an hourly basis 
(based on a 24H schedule).

* The total number of jams that day, compared to how many on average occur annually
on that specific day

* A line plot showing the number of jams for the specified days, and the number
of days back from the specified date (7, 14, 21 days back).

All viz is completed using ggplot2 (which can be easily converted to plotly or\
some other more interactive visualization library). 

Additionally, the back end data wrangling script organizes the data in such a way
that you can do some basic time series forecasting. This was an add-on I was planning
once the MVP of this dashboard was completed.

