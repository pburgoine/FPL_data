library(shiny)
library(ggplot2)

#dataset <- diamonds

fluidPage(
  
  titlePanel("My FPL Data 2016/17"),
  
  sidebarPanel(
    
    sliderInput('gameWeek', 'Gameweek', min=1, max=38,
                value=1, step=1, round=0)
  ),
  
  mainPanel(
    plotOutput('plot')
  )
)
